#!/bin/bash --login

echo $@
. /conda_env.sh
if [ "$1" = "test" ]; then
    nvidia-smi
    python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'));"
    python -c "import tensorflow as tf;  tf.test.is_gpu_available();"
else
    spleeter "$@"
fi