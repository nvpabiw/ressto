# Readme
ressto is a simple script to help organizing source based driven research

## Data Structure

```
bin/
	activate
	deactive
source/
	3df594ec800202f1	
		/persons
			peter.txt
		/images
			peter.png
		/documents
	(...)
persons/
	e14db89f9b127cce/
		/links
			d6384fe272d8ec59.ln -> ../../../sources/3df594ec800202f1/persons/peter.txt
		/images
 			9c147bcce79bde91.ln -> ../../../sources/3df594ec800202f1/images/peter.png

		/documents
	(...)
```

## Usage / Workflow
- `ressto init` - creates a new project
- `source bin/activate` - allows to use the $base env variable for faster navigation
- `ressto as example.org` - adds a new source (into $base/sources)
- `cd sources/e14db89f9b127cce/persons/` - navigates to the source based person data storage
- `ressto ap peter` - adds a new person (into $base/persons/)
- `touch peter.txt` - creates some person data under given source (sources/e14db89f9b127cce/persons/)
- `resto l peter.txt` - links the data to a person

(...) do some work

- `cd sources/e14db89f9b127cce/images`
- `resto l peter.png` - links the data to a person

(...) analyzing the results

- `ressto fp` - gives back the id of a person
- `cd $base/persons/3df594ec800202f11\links` - see all data 
