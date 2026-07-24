#!/usr/bin/env bash
set -euo pipefail

CONFIG="libs/hbb_common/src/config.rs"

sed -i 's|pub const RENDEZVOUS_SERVERS: &\[&str\] = &\["rs-ny.rustdesk.com"\];|pub const RENDEZVOUS_SERVERS: \&[&str] = \&["rustdesk.olgsys.com"];|' "$CONFIG"
sed -i 's|pub const RS_PUB_KEY: &str = "OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=";|pub const RS_PUB_KEY: \&str = "lGS++Q2liRIlLGdQvdC+SLaUMDH8tGZWN6I4vbdYLOk=";|' "$CONFIG"
sed -i 's|pub static ref APP_NAME: RwLock<String> = RwLock::new("RustDesk".to_owned());|pub static ref APP_NAME: RwLock<String> = RwLock::new("OLG Desk".to_owned());|' "$CONFIG"

echo "OLG Desk server defaults applied to $CONFIG"
