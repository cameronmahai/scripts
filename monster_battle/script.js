const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');
const battleUI = document.getElementById('battle-ui');
const battleText = document.getElementById('battle-text');

let gameState = 'explore';
let flashAlpha = 0; // For transition effect
const player = { x: 50, y: 50, size: 20, color: '#00f', speed: 5 };
const keys = {};

// Procedural Forest
const trees = Array.from({ length: 20 }, () => ({
    x: Math.random() * 800,
    y: Math.random() * 600,
    size: 30
}));

function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}
window.addEventListener('resize', resize);
resize();

window.addEventListener('keydown', (e) => keys[e.key] = true);
window.addEventListener('keyup', (e) => keys[e.key] = false);

function gameLoop() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Background based on state
    ctx.fillStyle = gameState === 'explore' ? '#2d5a27' : '#888';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    if (gameState === 'explore') {
        // Draw Trees
        ctx.fillStyle = '#1a3c18';
        trees.forEach(tree => ctx.fillRect(tree.x, tree.y, tree.size, tree.size));

        // Handle Movement
        if (keys['w']) player.y -= player.speed;
        if (keys['s']) player.y += player.speed;
        if (keys['a']) player.x -= player.speed;
        if (keys['d']) player.x += player.speed;

        // Draw Player
        ctx.fillStyle = player.color;
        ctx.fillRect(player.x, player.y, player.size, player.size);

        // Encounter Trigger
        if ((keys['w'] || keys['s'] || keys['a'] || keys['d']) && Math.random() < 0.01) {
            gameState = 'battle';
            flashAlpha = 1; // Start flash
            battleUI.classList.remove('hidden');
            battleText.innerText = 'A wild monster appeared!';
        }
    } else {
        // Battle Scene
        ctx.fillStyle = '#f00'; // Placeholder monster
        ctx.fillRect(canvas.width / 2 - 50, canvas.height / 3, 100, 100);
    }

    // Flash effect
    if (flashAlpha > 0) {
        ctx.fillStyle = `rgba(255, 255, 255, ${flashAlpha})`;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        flashAlpha -= 0.05;
    }
    
    requestAnimationFrame(gameLoop);
}

function battleAction(action) {
    if (action === 'run') {
        gameState = 'explore';
        battleUI.classList.add('hidden');
    } else {
        battleText.innerText = `You chose to ${action}! (Monster is confused)`;
    }
}

gameLoop();
