const nameInput = document.getElementById("name");
const durationInput = document.getElementById("duration");
const waitInput = document.getElementById("wait");

function envoyerValeur() {
    const nameValue = nameInput.value;
    const durationValue = durationInput.value;
    const waitValue = waitInput.value;

    if (nameValue == "" || durationValue == "" || waitValue == "") {
        alert("Veuillez remplir tous les champs");
    } else {
        var data = {
            name: nameValue,
            duration: durationValue,
            wait: waitValue,
        }

        var jsonData = JSON.stringify(data);
        window.location.href = "skp:ruby_function@" + encodeURIComponent(jsonData);
    }
}
