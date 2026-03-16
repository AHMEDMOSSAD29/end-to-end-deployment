document.addEventListener('DOMContentLoaded', () => {
    const navItems = document.querySelectorAll('.nav-item');
    const indicator = document.getElementById('nav-indicator');
    const sections = document.querySelectorAll('section');

    // 1. Move Indicator
    function updateIndicator(el) {
        if (!el) return;
        indicator.style.width = `${el.offsetWidth}px`;
        indicator.style.left = `${el.offsetLeft}px`;
        
        navItems.forEach(item => {
            item.classList.remove('text-white');
            item.classList.add('text-white/60');
        });
        el.classList.remove('text-white/60');
        el.classList.add('text-white');
    }

    if(navItems.length > 0) updateIndicator(navItems[0]);

    // 2. Click Logic
    navItems.forEach(item => {
        item.addEventListener('click', (e) => updateIndicator(e.target));
    });

    // 3. Scroll Spy (Detect active section)
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const id = entry.target.getAttribute('id');
                const activeLink = document.querySelector(`[data-section="${id}"]`);
                if (activeLink) updateIndicator(activeLink);
            }
        });
    }, { threshold: 0.3 });

    sections.forEach(section => observer.observe(section));

    // 4. Reveal Animations
    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.animationPlayState = 'running';
                entry.target.style.opacity = '1';
            }
        });
    }, { threshold: 0.1 });

    document.querySelectorAll('.fade-up').forEach(el => revealObserver.observe(el));
});