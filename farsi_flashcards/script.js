let baseDictionary = [];
let wordQueue = [];
let currentWord = {};
let score = 0;
let strikes = 0;
let timerInterval = null;
let timeLeft = 5000;

const farsiWordEl = document.getElementById('farsi-word');
const inputEl = document.getElementById('translation-input');
const feedbackEl = document.getElementById('feedback');
const scoreEl = document.getElementById('score');
const strikesEl = document.getElementById('strikes');
const timerEl = document.getElementById('timer');
const submitBtn = document.getElementById('submit-btn');

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
    wordQueue = [...baseDictionary];
    for (let i = wordQueue.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [wordQueue[i], wordQueue[j]] = [wordQueue[j], wordQueue[i]];
    }
}

function startTimer() {
    clearInterval(timerInterval);
    timeLeft = 5000;
    timerEl.innerText = "5.00";
    timerInterval = setInterval(() => {
        timeLeft -= 10;
        timerEl.innerText = (timeLeft / 1000).toFixed(2);
        if (timeLeft <= 0) {
            clearInterval(timerInterval);
            registerStrike("Too slow!");
        }
    }, 10);
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
    startTimer();
}

function registerStrike(message) {
    clearInterval(timerInterval);
    strikes++;
    strikesEl.innerText = strikes;
    
    if (strikes >= 3) {
        feedbackEl.innerText = `${message} The word was "${currentWord.english.join(', ')}"`;
        feedbackEl.style.color = "red";
        strikes = 0;
        strikesEl.innerText = strikes;
        setTimeout(nextWord, 3000);
    } else {
        feedbackEl.innerText = `${message} (${3 - strikes} strikes left)`;
        feedbackEl.style.color = "red";
        setTimeout(nextWord, 1000);
    }
}

function checkAnswer() {
    const translation = inputEl.value.trim().toLowerCase();
    // Check if input matches any of the accepted English definitions
    if (currentWord.english.includes(translation)) {
        clearInterval(timerInterval);
        score++;
        scoreEl.innerText = score;
        feedbackEl.innerText = "Correct!";
        feedbackEl.style.color = "green";
        strikes = 0;
        strikesEl.innerText = strikes;
        setTimeout(nextWord, 1000);
    } else {
        registerStrike("Wrong!");
    }
}

submitBtn.addEventListener('click', checkAnswer);

inputEl.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        checkAnswer();
    }
});

loadDictionary();
