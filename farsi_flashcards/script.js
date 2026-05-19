let baseDictionary = [];
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

// Load dictionary from JSON file
async function loadDictionary() {
    try {
        const response = await fetch('dictionary.json');
        baseDictionary = await response.json();
        resetQueue();
        nextWord();
    } catch (error) {
        console.error('Error loading dictionary:', error);
        farsiWordEl.innerText = "Error loading dictionary.";
    }
}

function resetQueue() {
    // Fisher-Yates shuffle
    wordQueue = [...baseDictionary];
    for (let i = wordQueue.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [wordQueue[i], wordQueue[j]] = [wordQueue[j], wordQueue[i]];
    }
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

inputEl.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        checkAnswer();
    }
});

loadDictionary();
