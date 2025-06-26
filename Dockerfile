FROM container-public.repo.cdp.clouderagovt.com/cloudera-public/cloudera/cdsw/ml-runtime-pbj-workbench-python3.12-govcloud:2025.07.1-b6

ENV \
    ML_RUNTIME_EDITION="Custom JupyterLab Runtime 2025.07.1-b6" \
    ML_RUNTIME_EDITOR="JupyterLab" \
    ML_RUNTIME_JUPYTER_KERNEL_NAME="python3" \
    ML_RUNTIME_DESCRIPTION="Custom JupyterLab Runtime" \
    JUPYTERLAB_WORKSPACES_DIR=/tmp

LABEL \
      com.cloudera.ml.runtime.edition=$ML_RUNTIME_EDITION \
      com.cloudera.ml.runtime.description=$ML_RUNTIME_DESCRIPTION \
      com.cloudera.ml.runtime.editor=$ML_RUNTIME_EDITOR

COPY ml-runtime-editor /usr/local/bin/ml-runtime-editor
RUN chmod +x /usr/local/bin/ml-runtime-editor

RUN pip3 install jupyterlab