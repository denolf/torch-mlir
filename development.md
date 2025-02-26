# Checkout and build from source

## Check out the code

```shell
git clone https://github.com/llvm/torch-mlir
cd torch-mlir
git submodule update --init
```

## Setup your Python VirtualEnvironment and Dependencies

Also, ensure that you have the appropriate `python-dev` package installed
to access the Python development libraries / headers.

```shell
python -m venv mlir_venv
source mlir_venv/bin/activate
# Some older pip installs may not be able to handle the recent PyTorch deps
python -m pip install --upgrade pip
# Install latest PyTorch nightlies and build requirements.
python -m pip install -r requirements.txt
```

## Build Python Packages

We have preliminary support for building Python packages. This can be done
with the following commands:

```
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
CMAKE_GENERATOR=Ninja python setup.py bdist_wheel
```

## CMake Build

Two setups are possible to build: in-tree and out-of-tree. The in-tree setup is the most straightforward, as it will build LLVM dependencies as well.

### Building torch-mlir in-tree

The following command generates configuration files to build the project *in-tree*, that is, using llvm/llvm-project as the main build. This will build LLVM as well as torch-mlir and its subprojects.

```shell
cmake -GNinja -Bbuild \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DPython3_FIND_VIRTUALENV=ONLY \
  -DLLVM_ENABLE_PROJECTS=mlir \
  -DLLVM_EXTERNAL_PROJECTS="torch-mlir;torch-mlir-dialects" \
  -DLLVM_EXTERNAL_TORCH_MLIR_SOURCE_DIR=`pwd` \
  -DLLVM_EXTERNAL_TORCH_MLIR_DIALECTS_SOURCE_DIR=`pwd`/externals/llvm-external-projects/torch-mlir-dialects \
  -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
  -DLLVM_TARGETS_TO_BUILD=host \
  externals/llvm-project/llvm
```
The following additional quality of life flags can be used to reduce build time:
* Enabling ccache:
```shell
  -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
```
* Enabling LLD (links in seconds compared to minutes)
```shell
  -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld"
# Use --ld-path= instead of -fuse-ld=lld for clang > 13
```

### Building against a pre-built LLVM

If you have built llvm-project separately in the directory `$LLVM_INSTALL_DIR`, you can also build the project *out-of-tree* using the following command as template:
```shell
cmake -GNinja -Bbuild \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DPython3_FIND_VIRTUALENV=ONLY \
  -DMLIR_DIR="$LLVM_INSTALL_DIR/lib/cmake/mlir/" \
  -DLLVM_DIR="$LLVM_INSTALL_DIR/lib/cmake/llvm/" \
  -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
  -DLLVM_TARGETS_TO_BUILD=host \
  .
```
The same QoL CMake flags can be used to enable ccache and lld. Be sure to have built LLVM with `-DLLVM_ENABLE_PROJECTS=mlir`.

Be aware that the installed version of LLVM needs in general to match the committed version in `externals/llvm-project`. Using a different version may or may not work.


### Build commands

After either cmake run (in-tree/out-of-tree), use one of the following commands to build the project:
```shell
# Build just torch-mlir (not all of LLVM)
cmake --build build --target tools/torch-mlir/all

# Run unit tests.
cmake --build build --target check-torch-mlir

# Run Python regression tests.
cmake --build build --target check-torch-mlir-python

# Build everything (including LLVM if in-tree)
cmake --build build
```

## Setup Python Environment to export the built Python packages
```shell
export PYTHONPATH=`pwd`/build/tools/torch-mlir/python_packages/torch_mlir:`pwd`/examples
```

## Running execution (end-to-end) tests:

```shell
# Run E2E TorchScript tests. These compile and run the TorchScript program
# through torch-mlir with a simplified MLIR CPU backend we call RefBackend
python -m e2e_testing.torchscript.main --filter Conv2d --verbose
```

[Example IR](https://gist.github.com/silvasean/e74780f8a8a449339aac05c51e8b0caa) for a simple 1 layer MLP to show the compilation steps from TorchScript.


Jupyter notebook:
```shell
python -m ipykernel install --user --name=torch-mlir --env PYTHONPATH "$PYTHONPATH"
# Open in jupyter, and then navigate to
# `examples/resnet_inference.ipynb` and use the `torch-mlir` kernel to run.
jupyter notebook
```


## Interactive Use

The `build_tools/write_env_file.sh` script will output a `.env`
file in the workspace folder with the correct PYTHONPATH set. This allows
tools like VSCode to work by default for debugging. This file can also be
manually `source`'d in a shell.

