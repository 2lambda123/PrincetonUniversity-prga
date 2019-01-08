# **P**rinceton **R**econfigurable **G**ate **A**rray

It's reconfigurable outside Princeton, too!

## Prerequisites

PRGA depends on the following libraries, tools, and Python modules:

- **Libraries**: [Boost Graph
  Library](https://www.boost.org/doc/libs/1_69_0/libs/graph/doc/index.html), 
  [Expat](https://libexpat.github.io/)
- **Tools**: [Google Proto Buffer](https://developers.google.com/protocol-buffers/),
  [Yosys](http://www.clifford.at/yosys/),
  [Verilog-to-Routing](https://verilogtorouting.org/),
  [Icarus Verilog](http://iverilog.icarus.com/)
- **Python modules**: [networkx](https://networkx.github.io/),
  [jinja2](http://jinja.pocoo.org/docs/2.10/),
  [protobuf](https://pypi.org/project/protobuf/),
  [mmh3](https://pypi.org/project/mmh3/),
  [lxml](https://lxml.de/),
  [enum34](https://pypi.org/project/enum34/),
  [xmltodict](https://github.com/martinblech/xmltodict),
  [hdlparse](https://kevinpt.github.io/hdlparse/)
- **Optional**: [Sphinx](http://www.sphinx-doc.org/en/master/examples.html) for building the
  docs

## Installation

Note that PRGA contains sub-modules. Run the following commands after cloning
this project to download the sub-modules:

```bash
cd /path/to/prga                        # cd to the root folder of PRGA
git submodule update --init --recursive # fetch sub-modules
```

Some part of the PRGA needs compilation. Run the following commands:

```bash
cd /path/to/prga                        # cd to the root folder of PRGA
mkdir build && cd build                 # that's where we will build everything
cmake3 ..                               # run CMake
make                                    # run Make
```

## Examples

Examples are provided in the `examples/` directory. Each example is a complete
use case of PRGA, including building a custom FPGA, running
Verilog-to-bitstream flow for a target design, then verifying the implemented
target design by simulating the RTL of the FPGA with the generated bitstream.
Each example is organized in the following hierarchy:

* `build.py`: the Python script for building the FPGA
* `{example}.v`: the target design
* `{example}_host.v`: the test host for the target design
* `io.pads`: the IO binding file
* `build/`:
    * `Makefile`: the Make script

Follow the commands below to run an example:

```bash
cd /path/to/prga                        # cd to the root folder of PRGA
source envscr/general.settings.sh       # set up environment
cd examples/small/build                 # cd to one of the example directories
make                                    # this will run all the way to post-implementation simulation
```

## Coding Styles
1. Use explicit `import`s to make searching for source code easier.
2. You will never have too many classes. Use different classes when there are
   different needs instead of sharing classes and add checking/validation logic.
3. Following Python's coding style (to be in practice in later commits):
    - Use CamelCase naming conventions for classes
    - Use underscore naming conventions instead of CamelCase for methods
    - Methods starting with *capitalized letter* are `staticmethod` or `classmethod` API
    - Methods starting with *lower-case letter* are API
    - Methods starting with *one underscore* are internal methods
    - Methods starting with *two underscores* are class-private methods
