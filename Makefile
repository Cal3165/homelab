.POSIX:
.PHONY: *
.EXPORT_ALL_VARIABLES:

KUBECONFIG = ~/.kube/config
KUBE_CONFIG_PATH = $(KUBECONFIG)

default: system external smoke-test post-install clean

apps: system external

omni:
	./omni/omnictl --omniconfig ./omni/config.yaml cluster template sync --file ./omni/cluster.yaml

omni-delete:
	./omni/omnictl --omniconfig ./omni/config.yaml cluster template delete --file ./omni/cluster.yaml

configure:
	./scripts/configure
	git status

metal:
	make -C metal

system:
	make -C apps

external:
	make -C external

smoke-test:
	make -C test filter=Smoke

post-install:
	@./scripts/hacks

tools:
	@docker run \
		--rm \
		--interactive \
		--tty \
		--network host \
		--env "KUBECONFIG=/root/.kube/config" \
		--volume "/var/run/docker.sock:/var/run/docker.sock" \
		--volume ${KUBECONFIG}:/root/.kube/config \
		--volume $(shell pwd):$(shell pwd) \
		--volume ${HOME}/.ssh:/root/.ssh \
		--volume ${HOME}/.terraform.d:/root/.terraform.d \
		--volume homelab-tools-cache:/root/.cache \
		--volume homelab-tools-nix:/nix \
		--workdir $(shell pwd) \
		docker.io/nixos/nix nix --experimental-features 'nix-command flakes' develop

test:
	make -C test

clean:
	docker compose --project-directory ./metal/roles/pxe_server/files down

docs:
	mkdocs serve

git-hooks:
	pre-commit install
