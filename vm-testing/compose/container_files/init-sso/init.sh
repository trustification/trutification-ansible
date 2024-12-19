#!/usr/bin/env bash

set -exo pipefail

# when making changes, sync everything below here with the helm charts

trap break INT

kcadm() { local cmd="$1" ; shift ; "$KCADM_PATH" "$cmd" --config /tmp/kcadm.config "$@" ; }

die() {
    echo "$*" 1>&2
    false
}

# TODO: once podman compose works, stop polling
while ! kcadm config credentials config --server "$KEYCLOAK_URL" --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD" &> /dev/null; do
  echo "Waiting for Keycloak to start up..."
  sleep 5
done

echo "Keycloak ready"

# now we can do the actual work

# create realm
REALM_OPTS=()
REALM_OPTS+=(-s enabled=true)
REALM_OPTS+=(-s "displayName=Trusted Content")
REALM_OPTS+=(-s registrationAllowed=true)
REALM_OPTS+=(-s resetPasswordAllowed=true)
REALM_OPTS+=(-s loginWithEmailAllowed=false)

# if Keycloak has an internal name, set the external name here
if [[ -n "$SSO_FRONTEND_URL" ]]; then
REALM_OPTS+=(-s "attributes.frontendUrl=$SSO_FRONTEND_URL")
fi

if kcadm get "realms/${REALM}" &> /dev/null ; then
  # exists -> update
  kcadm update "realms/${REALM}" "${REALM_OPTS[@]}"
else
  # need to create
  kcadm create realms -s "realm=${REALM}" "${REALM_OPTS[@]}"
fi

if [[ -n "$GITHUB_CLIENT_ID" ]]; then
  ID=$(kcadm get identity-provider/instances/github -r "${REALM}" --fields alias --format csv --noquotes)
  if [[ -n "$ID" ]]; then
    kcadm update "identity-provider/instances/${ID}" -r "${REALM}" -s enabled=true -s 'config.useJwksUrl="true"' -s "config.clientId=$GITHUB_CLIENT_ID" -s "config.clientSecret=$GITHUB_CLIENT_SECRET"
  else
    kcadm create identity-provider/instances -r "${REALM}" -s alias=github -s providerId=github -s enabled=true -s 'config.useJwksUrl="true"' -s "config.clientId=$GITHUB_CLIENT_ID" -s "config.clientSecret=$GITHUB_CLIENT_SECRET"
  fi
fi

# create realm roles
kcadm create roles -r "${REALM}" -s name=chicken-user || true
kcadm create roles -r "${REALM}" -s name=chicken-manager || true
kcadm create roles -r "${REALM}" -s name=chicken-admin || true
# add chicken-user as default role
kcadm add-roles -r "${REALM}" --rname "default-roles-${REALM}" --rolename chicken-user

MANAGER_ID=$(kcadm get roles -r "${REALM}" --fields id,name --format csv --noquotes | grep ",chicken-manager" | awk -F ',' '{print $1}')

# create scopes
# shellcheck disable=SC2043
for i in read:document; do
kcadm create client-scopes -r "${REALM}" -s "name=$i" -s protocol=openid-connect || true
done

for i in create:document delete:document; do
kcadm create client-scopes -r "${REALM}" -s "name=$i" -s protocol=openid-connect || true
ID=$(kcadm get client-scopes -r "${REALM}" --fields id,name --format csv --noquotes | grep ",${i}" | awk -F ',' '{print $1}')
# add all scopes to the chicken-manager
kcadm create "client-scopes/${ID}/scope-mappings/realm" -r "${REALM}" -b '[{"name":"chicken-manager", "id":"'"${MANAGER_ID}"'"}]' || true
done

# create clients - frontend
ID=$(kcadm get clients -r "${REALM}" --query exact=true --query "clientId=frontend" --fields id --format csv --noquotes)
CLIENT_OPTS=()
CLIENT_OPTS+=(-s "redirectUris=${REDIRECT_URIS}")
if [[ -n "$ID" ]]; then
  # TODO: replace with update once https://github.com/keycloak/keycloak/issues/12484 is fixed
  # kcadm update "clients/${ID}" -r "${REALM}" -f /etc/init-data/client.json "${CLIENT_OPTS[@]}"
  kcadm delete "clients/${ID}" -r "${REALM}"
  kcadm create clients -r "${REALM}" -f "${INIT_DATA}/client-frontend.json" "${CLIENT_OPTS[@]}"
else
  kcadm create clients -r "${REALM}" -f "${INIT_DATA}/client-frontend.json" "${CLIENT_OPTS[@]}"
fi

# create walker service account
ID=$(kcadm get clients -r "${REALM}" --query exact=true --query "clientId=walker" --fields id --format csv --noquotes)
CLIENT_OPTS=()
if [[ -n "$ID" ]]; then
  # TODO: replace with update once https://github.com/keycloak/keycloak/issues/12484 is fixed
  # kcadm update "clients/${ID}" -r "${REALM}" -f /etc/init-data/client.json "${CLIENT_OPTS[@]}"
  kcadm delete "clients/${ID}" -r "${REALM}"
  kcadm create clients -r "${REALM}" -f "${INIT_DATA}/client-walker.json" "${CLIENT_OPTS[@]}"
else
  kcadm create clients -r "${REALM}" -f "${INIT_DATA}/client-walker.json" "${CLIENT_OPTS[@]}"
fi
kcadm add-roles -r "${REALM}" --uusername service-account-walker --rolename chicken-manager
# now set the client-secret
ID=$(kcadm get clients -r "${REALM}" --query exact=true --query "clientId=walker" --fields id --format csv --noquotes)
kcadm update "clients/${ID}" -r "${REALM}" -s "secret=${WALKER_SECRET}"

# create user
ID=$(kcadm get users -r "${REALM}" --query exact=true --query "username=${CHICKEN_ADMIN}" --fields id --format csv --noquotes)
if [[ -n "$ID" ]]; then
  kcadm update "users/$ID" -r "${REALM}" -s enabled=true
else
  kcadm create users -r "${REALM}" -s "username=${CHICKEN_ADMIN}" -s enabled=true
fi

# set role
kcadm add-roles -r "${REALM}" --uusername "${CHICKEN_ADMIN}" --rolename chicken-admin
kcadm add-roles -r "${REALM}" --uusername "${CHICKEN_ADMIN}" --rolename chicken-manager

# set password
ID=$(kcadm get users -r "${REALM}" --query exact=true --query "username=${CHICKEN_ADMIN}" --fields id --format csv --noquotes)
kcadm update "users/${ID}/reset-password" -r "${REALM}" -s type=password -s "value=${CHICKEN_ADMIN_PASSWORD}" -s temporary=false -n

if [[ -f "${INIT_DATA}/there-is-more.sh" ]]; then
  echo Performing additional setup
  . "${INIT_DATA}/there-is-more.sh"
fi

echo SSO initialization complete
