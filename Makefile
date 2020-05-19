.PHONY: build-and-push-docker-image

build-and-push-docker-image: docker-pushed-id.txt

docker-pushed-id.txt: docker-image-id.txt
	docker push avdi/idw
	cp $< $@

docker-image-id.txt: Dockerfile
	docker build -t avdi/idw --iidfile $@ .