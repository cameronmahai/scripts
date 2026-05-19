// Expanded dictionary
const baseDictionary = [
    { farsi: "سلام", english: "hello" },
    { farsi: "خداحافظ", english: "goodbye" },
    { farsi: "بله", english: "yes" },
    { farsi: "خیر", english: "no" },
    { farsi: "ممنون", english: "thank you" },
    { farsi: "لطفاً", english: "please" },
    { farsi: "دوست", english: "friend" },
    { farsi: "کتاب", english: "book" },
    { farsi: "آب", english: "water" },
    { farsi: "غذا", english: "food" },
    { farsi: "خانواده", english: "family" },
    { farsi: "خانه", english: "house" },
    { farsi: "کار", english: "work" },
    { farsi: "ساعت", english: "clock" },
    { farsi: "شب", english: "night" }
];

let wordQueue = [];
let currentWord = {};
let score = 0;
let strikes = 0;

const farsiWordEl = document.getElementById('farsi-word');
const inputEl = document.getElementById('translation-input');
const feedbackEl = document.getElementById('feedback');
const scoreEl = document.getElementById('score');
const strikesEl = document.getElementById('strikes');
const submitBtn = document.getElementById('submit-btn');

function resetQueue() {
    wordQueue = [...baseDictionary].sort(() => Math.random() - 0.5);
}

function nextWord() {
    if (wordQueue.length === 0) {
        resetQueue();
    }
    currentWord = wordQueue.pop();
    farsiWordEl.innerText = currentWord.farsi;
    inputEl.value = '';
    feedbackEl.innerText = '';
    inputEl.focus();
}

function checkAnswer() {
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
}

submitBtn.addEventListener('click', checkAnswer);

// Allow Enter key
inputEl.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        checkAnswer();
    }
});

resetQueue();
nextWord();
