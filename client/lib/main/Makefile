
build: components index.coffee main.css
	@component build --dev --use component-coffee

components: component.json
	@component install --dev

clean:
	rm -fr build components template.js

.PHONY: clean
