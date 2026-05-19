// Placeholder dictionary for now, as I don't have a live API endpoint
const dictionary = [
    { farsi: "سلام", english: "hello" },
    { farsi: "خداحافظ", english: "goodbye" },
    { farsi: "بله", english: "yes" },
    { farsi: "خیر", english: "no" },
    { farsi: "ممنون", english: "thank you" }
];

let currentWord = {};
let score = 0;
let strikes = 0;

const farsiWordEl = document.getElementById('farsi-word');
const inputEl = document.getElementById('translation-input');
const feedbackEl = document.getElementById('feedback');
const scoreEl = document.getElementById('score');
const strikesEl = document.getElementById('strikes');
const submitBtn = document.getElementById('submit-btn');

function nextWord() {
    currentWord = dictionary[Math.floor(Math.random() * dictionary.length)];
    farsiWordEl.innerText = currentWord.farsi;
    inputEl.value = '';
    feedbackEl.innerText = '';
}

submitBtn.addEventListener('click', () => {
    const translation = inputEl.value.trim().toLowerCase();
    if (translation === currentWord.english) {
        score++;
        scoreEl.innerText = score;
        feedbackEl.innerText = "Correct!";
        feedbackEl.style.color = "green";
        strikes = 0;
        strikesEl.innerText = strikes;
        setTimeout(nextWord, 1000);
    } else {
        strikes++;
        strikesEl.innerText = strikes;
        feedbackEl.innerText = "Wrong!";
        feedbackEl.style.color = "red";
        if (strikes >= 3) {
            feedbackEl.innerText = `Too many strikes! The word was "${currentWord.english}"`;
            strikes = 0;
            strikesEl.innerText = strikes;
            setTimeout(nextWord, 2000);
        }
    }
});

nextWord();
