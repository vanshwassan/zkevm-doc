# How to run this documentation (locally)
## Install mkdocs
```
pip3 install mkdocs
```

In case you have a rendering problem with the pieces of code, please execute:
```
pip install --upgrade mkdocs
```

## Install mkdocs-material theme
```
pip install mkdocs-material
```

## Run the webserver
At the mkdocs directory execute:

```
mkdocs serve
```


# Other option for deploying static content on server

## Clone repo
```
git clone https://github.com/hermeznetwork/docs.git
```
## Go to mkdocs folder
```
cd mkdocs
```

## Deploy static content
```
../pull-and-build-mkdocs.sh
```
This automatically pulls last changes, and builds mkdocs static content.
