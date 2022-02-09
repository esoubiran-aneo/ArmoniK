pushd $(dirname "${BASH_SOURCE[0]}")
pushd $(pwd -P)/../../storage/onpremise
STORAGE_PATH=$(pwd -P)

# Armonik storage namespace in the Kubernetes
export ARMONIK_STORAGE_NAMESPACE=armonik-storage

# Directory path of the Redis certificates
export ARMONIK_STORAGE_REDIS_CERTIFICATES_DIRECTORY=$STORAGE_PATH/../../security/certificates/redis

# Name of Redis secret
export ARMONIK_STORAGE_REDIS_SECRET_NAME=redis-storage-secret

# Directory path of the ActiveMQ credentials
export ARMONIK_STORAGE_ACTIVEMQ_CREDENTIALS_DIRECTORY=$STORAGE_PATH/../../security/credentials
export ARMONIK_STORAGE_ACTIVEMQ_CERTIFICATES_DIRECTORY=$STORAGE_PATH/../../security/certificates/activemq

# Name of ActiveMQ secret
export ARMONIK_STORAGE_ACTIVEMQ_SECRET_NAME=activemq-storage-secret

# Directory path of the MongoDB certificates
export ARMONIK_STORAGE_MONGODB_CERTIFICATES_DIRECTORY=$STORAGE_PATH/../../security/certificates/mongodb

# Name of MongoDB secret
export ARMONIK_STORAGE_MONGODB_SECRET_NAME=mongodb-storage-secret

popd
popd
env | grep --color=always ARMONIK