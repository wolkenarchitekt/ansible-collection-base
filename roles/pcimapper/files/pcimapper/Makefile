VENV = .venv
VENV_BIN = $(VENV)/bin

virtualenv-create:
	python3 -m venv $(VENV)
	$(VENV_BIN)/pip install --upgrade pip setuptools \
		&& $(VENV_BIN)/pip install -r requirements.txt \
		&& $(VENV_BIN)/pip install .
