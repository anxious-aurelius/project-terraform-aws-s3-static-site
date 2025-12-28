document.addEventListener("DOMContentLoaded", function () {
    const button = document.getElementById("actionBtn");
    const message = document.getElementById("message");

    button.addEventListener("click", function () {
        message.textContent =
            "This site is successfully hosted on AWS S3 using Terraform 🚀";
    });
});
