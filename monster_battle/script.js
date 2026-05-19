const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');
const battleUI = document.getElementById('battle-ui');

// Basic Game State
let gameState = 'explore'; // 'explore' or 'battle'
const player = { x: 50, y: 50, size: 20, color: 'blue' };

function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}
window.addEventListener('resize', resize);
resize();

function gameLoop() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    if (gameState === 'explore') {
        // Draw player
        ctx.fillStyle = player.color;
        ctx.fillRect(player.x, player.y, player.size, player.size);
    }
    
    requestAnimationFrame(gameLoop);
}

// Basic Movement
window.addEventListener('keydown', (e) => {
    if (gameState !== 'explore') return;
    const speed = 10;
    if (e.key === 'w') player.y -= speed;
    if (e.key === 's') player.y += speed;
    if (e.key === 'a') player.x -= speed;
    if (e.key === 'd') player.x += speed;

    // Simulate Encounter
    if (Math.random() < 0.05) {
        gameState = 'battle';
        battleUI.classList.remove('hidden');
    }
});

function battleAction(action) {
    if (action === 'run') {
        gameState = 'explore';
        battleUI.classList.add('hidden');
    }
}

gameLoop();
