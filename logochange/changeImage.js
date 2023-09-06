function changeImage() {
    var image = document.getElementById("logo");
    var randomIndex = Math.floor(Math.random() * 41) + 1;
    var randomImageName = "/logochange/logos/" + randomIndex + ".png";
    console.log("AAAAAAAAaa" + randomIndex)
    
    image.src = randomImageName;
}