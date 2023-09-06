var previousRandomIndex = -1;

function changeImage() {
    var image = document.getElementById("logo");
    var randomIndex;
    
    do {
        randomIndex = Math.floor(Math.random() * 41) + 1;
    } while (randomIndex === previousRandomIndex);

    previousRandomIndex = randomIndex;

    var randomImageName = "/logochange/logos/" + randomIndex + ".png";
    image.src = randomImageName;
}