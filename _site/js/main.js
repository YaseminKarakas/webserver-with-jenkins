// Dark mode toggle functionality
const htmlElement = document.documentElement;
const darkModeToggle = document.getElementById('dark-mode-toggle');

// Check for saved theme preference or use preferred color scheme
const savedTheme = localStorage.getItem('theme');
if (savedTheme) {
    htmlElement.className = savedTheme;
    darkModeToggle.classList.toggle('active', savedTheme === 'dark');
} else {
    // Use preferred color scheme if no saved preference
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        htmlElement.className = 'dark';
        darkModeToggle.classList.add('active');
    }
}

// Toggle dark/light mode
darkModeToggle.addEventListener('click', () => {
    if (htmlElement.className === 'light') {
        htmlElement.className = 'dark';
        localStorage.setItem('theme', 'dark');
        darkModeToggle.classList.add('active');
    } else {
        htmlElement.className = 'light';
        localStorage.setItem('theme', 'light');
        darkModeToggle.classList.remove('active');
    }
});
