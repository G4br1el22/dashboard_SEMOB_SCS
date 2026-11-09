from dotenv import dotenv_values
import pytest
from backend.tools.configurar_banco import make_uri, save_config


def test_uri_encodes_special_characters():
    assert make_uri("cluster.exemplo.mongodb.net", "analista@local", "senha:@/#$") == (
        "mongodb+srv://analista%40local:senha%3A%40%2F%23%24@cluster.exemplo.mongodb.net/?retryWrites=false")


@pytest.mark.parametrize("host,user,password", [
    ("evil.example", "user", "secret"), ("cluster.exemplo.mongodb.net", "", "secret"),
    ("cluster.exemplo.mongodb.net", "user", ""),
])
def test_configuration_rejects_incomplete_or_invalid_input(host, user, password):
    with pytest.raises(ValueError):
        make_uri(host, user, password)


def test_save_local_config_preserves_other_settings(tmp_path):
    path = tmp_path / ".env"
    path.write_text("CUSTOM=preservado\n", encoding="utf-8")
    uri = make_uri("cluster.exemplo.mongodb.net", "sintetico", "apenas-teste")
    save_config(uri, "semob", path)
    values = dotenv_values(path)
    assert values["CUSTOM"] == "preservado"
    assert values["MONGODB_URI"] == uri
    assert values["SEMOB_SOURCE"] == "mongo"
