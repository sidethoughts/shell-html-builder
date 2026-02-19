# shell-html-builder
this is my small shell-html-builder. it scans all the html-files for a "@include-modulename.html" and then copies the corresponding html for this module. 

instead of editing the files directly, all the edited files are saved in a new directory in the right file hierarchie.

lastly it formats the html with [js-beautify](https://github.com/beautifier/js-beautify), so you need to have js-beautify installed globally (or locally)


at the beginning you have to adjust the configuration with your own folder names 

at the moment you just run the programm besides your html files ypu want to build with:
```sh
bash build.sh
```

# planing / to do / future ideas
- check, what happends if two @includes are right after each other
- copying the html first, so that every html file is in the new directory, now just the ones with a module inside are getting copied
- adding separate config files for the folder and the js-beautify options
- renaming?
- adding arguments to @includes for dynamic modules, text to be displayed inside of modules
- installation with makefile to save it in /bin