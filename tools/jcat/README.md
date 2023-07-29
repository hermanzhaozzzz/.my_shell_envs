# JCAT

`jcat` is a self-contained command line tool for viewing jupyter notebook files in terminal. It parses notebook's underlying json content, hence it runs *without the dependency of jupyter/ipython core*.

### Example notebook ([link](https://github.com/ktw361/jcat/blob/master/examples/example-cifar10.ipynb))
![nb](https://user-images.githubusercontent.com/23008175/190875963-917e9b7a-a68c-491a-8653-72e748d8546d.png)

* Running with `jcat examples/example-cifar10.ipynb -a`:
<details>
    <summary> Output (click to expand)</summary>

```
=========================================================================
# `markdown`
# CIFAR - 10 
## Decode data
=========================================================================
# `markdown`
Activate virtual environment
=========================================================================
# In [1]: 
%%bash
source ~/kerai/bin/activate
=========================================================================
# `markdown`
### Imports
=========================================================================
# In [2]: 
%matplotlib inline
from helper import get_class_names, get_train_data, get_test_data, plot_images
-------------------------------------------------------------------------
# `stderr`
Using TensorFlow backend.

=========================================================================
# `markdown`
Get class names
=========================================================================
# In [3]: 
class_names = get_class_names()
class_names
-------------------------------------------------------------------------
# `stdout`
Decoding file: data/batches.meta

# Out[3]: 
['airplane',
 'automobile',
 'bird',
 'cat',
 'deer',
 'dog',
 'frog',
 'horse',
 'ship',
 'truck']
=========================================================================
```
</details>

## Prerequisites

Most systems with `g++` and `make` installed should be fine.

**Looking for easier installation?** Checkout the [python implementation](https://github.com/ktw361/nbcat).

## Build and Install

Clone this repo, if you want to be able to easily uninstall jcat use `checkinstall`.
```
sudo apt install checkinstall
cd jcat
sudo checkinstall
```
Otherwise, you can use `make` to install.
```
cd jcat
make
sudo make install
```
Optionally, one could use `./jcat` without runing `sudo make install`;  
or use `make install PREFIX=/path/to/install` for alternative installation directory (by default is `/usr/local`, which puts `jat` into `/usr/local/bin`).

## Usage

```
Usage: jcat FILE [OPTION]

FILE:	A json parsable notebook file (*.ipynb).

OPTION:
  -a:	Align prompt (In/Out) for copy.
```

### Use jcat with grep to get rid of annoying image datas

* output of `cat`:

![grep_cat](https://user-images.githubusercontent.com/23008175/89075159-2237ab80-d3b0-11ea-8872-d3361705833c.png)

* output of `jcat':

![grep_jcat](https://user-images.githubusercontent.com/23008175/89075189-34b1e500-d3b0-11ea-8fcd-6289cae6da17.png)


## Uninstall

`rm /usr/local/bin/jcat`, if no extra `$PREFIX` is supplied during installation.

## License

Distributed uder the [Boost Software License](http://www.boost.org/users/license.html). 

## Acknoledgement

jcat parse notebook with [jsoncons](https://github.com/danielaparker/jsoncons), a header only c++ json library.  
Example notebook from: https://github.com/09rohanchopra/cifar10/blob/master/cifar10-basic.ipynb
