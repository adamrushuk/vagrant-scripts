# Vagrant Scripts

A central repository for reusable Vagrant provisioning scripts.

## Usage

1. From the new "target" repo, run the following command to add a submodule using this repo (`adamrushuk/vagrant-scripts`) and clone into the local `/Vagrant` folder:  
`git submodule add git@github.com:adamrushuk/vagrant-scripts.git Vagrant`
1. A `.gitmodules` file will be created in the root of the repo, eg:

```bash
[submodule "Vagrant"]
	path = Vagrant
	url = git@github.com:adamrushuk/vagrant-scripts.git
```

## Reference

https://gist.github.com/gitaarik/8735255
https://stackoverflow.com/questions/5828324/update-git-submodule-to-latest-commit-on-origin/5828396#5828396
