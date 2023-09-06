var previousRandomIndex = 0;

function changeImage() {
    var image = document.getElementById("logo");
    var randomIndex;
    
    do {
        randomIndex = Math.floor(Math.random() * 53) + 1;
    } while (randomIndex === previousRandomIndex);
    
    previousRandomIndex = randomIndex;
    var randomImageName = "/resources/logos/" + randomIndex + ".jpg";
    image.src = randomImageName;
}