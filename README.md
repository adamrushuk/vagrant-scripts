# Vagrant Scripts

A central repository for reusable Vagrant provisioning scripts.

## Usage

### Create submodule in another repository

1. From the new "target" repo, run the following command to add a submodule using this repo (`adamrushuk/vagrant-scripts`) and clone into the local `/Vagrant` folder:  
`git submodule add git@github.com:adamrushuk/vagrant-scripts.git Vagrant`
1. A `.gitmodules` file will be created in the root of the repo, eg:
    ```bash
    [submodule "Vagrant"]
      path = Vagrant
      url = git@github.com:adamrushuk/vagrant-scripts.git
    ```
1. The changes will be staged for you ready to commit:
    ```
    git commit -am "Init submodule"
    git push
    ```

### Pull latest changes from new repository

If this source repository (`adamrushuk/vagrant-scripts`) is updated, you can pull the latest changes into your "target" repo by running:  
`git submodule update --remote --merge`

### Remove this Vagrant submodule

Run the commands below:

```
git submodule deinit --all
git add .gitmodules
git rm --cached Vagrant -r
Remove-Item -Recurse .git/modules/Vagrant
```

## Reference

https://gist.github.com/gitaarik/8735255  
https://stackoverflow.com/questions/5828324/update-git-submodule-to-latest-commit-on-origin/5828396#5828396
https://blog.aevitas.co.uk/removing-a-git-submodule/
