// Mobile Navigation
        const hamburger = document.querySelector('.hamburger');
        const navMenu = document.querySelector('.nav-menu');
        if(hamburger) {
                hamburger.addEventListener('click', () => {
                    hamburger.classList.toggle('active');
                    navMenu.classList.toggle('active');
                });
        }
        // FAQ Toggle
        function toggleFAQ(element) {
            const faqItem = element.parentElement;
            const answer = faqItem.querySelector('.faq-answer');
            const toggle = element.querySelector('.faq-toggle');
            
            faqItem.classList.toggle('active');
            
            if (faqItem.classList.contains('active')) {
                answer.style.maxHeight = answer.scrollHeight + 'px';
                toggle.textContent = '−';
            } else {
                answer.style.maxHeight = '0';
                toggle.textContent = '+';
            }
        }

        // Smooth scroll to enrollment
        function scrollToEnrollment() {
            document.getElementById('enrollment').scrollIntoView({
                behavior: 'smooth'
            });
        }

        // Form submission
        const enrollmentForm = document.getElementById('enrollmentForm');
        if(enrollmentForm) {
            enrollmentForm.addEventListener('submit', function(e) {
                e.preventDefault();
                
                // Get form data
                const formData = new FormData(this);
                const data = Object.fromEntries(formData);
                
                // Here you would typically send the data to your backend
                console.log('Enrollment data:', data);
                
                // Show success message
                alert('Thank you for enrolling! You will receive a confirmation email shortly.');
            });
        }

        // Project showcase animation
        const projectCards = document.querySelectorAll('.project-card');
        let currentCard = 0;

        function rotateProjects() {
            projectCards[currentCard].classList.remove('active');
            currentCard = (currentCard + 1) % projectCards.length;
            projectCards[currentCard].classList.add('active');
        }

        // Rotate project cards every 3 seconds
        setInterval(rotateProjects, 3000);

        // Callback form submission
        const callbackForm = document.getElementById('callbackForm');
        if(callbackForm) {
            document.getElementById('callbackForm').addEventListener('submit', function(e) {
                e.preventDefault();
                
                const formData = new FormData(this);
                const data = Object.fromEntries(formData);
                
                console.log('Callback request data:', data);
                
                alert('Thank you for your request! Our team will contact you shortly.');
            });
        }
        // Smooth scroll to callback section
        function scrollToCallback() {
            document.querySelector('.callback-section').scrollIntoView({
                behavior: 'smooth'
            });
        }




// Waitlist modal functionality
const modal = document.getElementById('waitlistModal');
const waitlistBtns = document.querySelectorAll('.waitlist-btn');
const closeBtn = document.querySelector('.close');
const form = document.getElementById('waitlistForm');
const courseSelect = document.querySelector('#waitlistForm select');

waitlistBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        modal.style.display = 'block';
        const courseValue = btn.getAttribute('data-course');
        if (courseValue && courseSelect) {
            courseSelect.value = courseValue;
        }
    });
});

closeBtn.addEventListener('click', () => {
    modal.style.display = 'none';
});

window.addEventListener('click', (e) => {
    if (e.target === modal) {
        modal.style.display = 'none';
    }
});

form.addEventListener('submit', (e) => {
    e.preventDefault();
    alert('Thank you for joining our waitlist! We\'ll notify you when the course becomes available.');
    modal.style.display = 'none';
    form.reset();
});

document.querySelectorAll('.faq-item').forEach(item => {
    const question = item.querySelector('.faq-question');
    const answer = item.querySelector('.faq-answer');
    const toggle = item.querySelector('.faq-toggle');

    question.addEventListener('click', () => {
        const isOpen = answer.style.display === 'block';
        
        // Close all other FAQs
        document.querySelectorAll('.faq-answer').forEach(a => a.style.display = 'none');
        document.querySelectorAll('.faq-toggle').forEach(t => t.textContent = '+');
        
        // Toggle current FAQ
        if (!isOpen) {
            answer.style.display = 'block';
            toggle.textContent = '−';
        }
    });
});
// Smooth scroll to callback section
function scrollToCallback() {
    document.querySelector('.callback-section').scrollIntoView({
        behavior: 'smooth'
    });
}



        // Enhanced JavaScript with better animations and interactions
        // Smooth scrolling with easing
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Enhanced header scroll effect
        window.addEventListener('scroll', function() {
            const header = document.querySelector('header');
            const scrolled = window.scrollY > 100;
            
            if (scrolled) {
                header.style.background = 'rgba(255, 255, 255, 0.95)';
                header.style.backdropFilter = 'blur(24px)';
                header.style.borderBottom = '1px solid rgba(31, 41, 55, 0.1)';
            } else {
                header.style.background = 'rgba(255, 255, 255, 0.95)';
                header.style.backdropFilter = 'blur(10px)';
                header.style.borderBottom = '1px solid var(--border)';
            }
        });

        // Enhanced card animations
        document.querySelectorAll('.course-card, .profile-card, .testimonial-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-2px)';
                this.style.boxShadow = '0 4px 12px rgba(0, 53, 59, 0.1)';
                this.style.transition = 'all 0.2s ease';
            });
            
            card.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0)';
                this.style.boxShadow = 'none';
            });
        });

        // Newsletter form with better feedback
        const newsLetterform = document.querySelector('.newsletter-form');
        if(newsLetterform) {
            newsLetterform.addEventListener('submit', function(e) {
                e.preventDefault();
                const email = this.querySelector('.email-input').value;
                const button = this.querySelector('.subscribe-btn');
                
                button.textContent = 'Joining...';
                button.disabled = true;
                
                setTimeout(() => {
                    alert('Welcome to the inner circle! Check your email for exclusive content.');
                    this.querySelector('.email-input').value = '';
                    button.textContent = 'Join the Circle';
                    button.disabled = false;
                }, 1500);
            });
        }

        // Advanced intersection observer for animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -100px 0px'
        };

        const observer = new IntersectionObserver(function(entries) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('fade-in-up');
                }
            });
        }, observerOptions);

        document.querySelectorAll('.course-card, .testimonial-card, .stat-item, .profile-card').forEach(el => {
            observer.observe(el);
        });


        form.addEventListener('submit', (e) => {
            e.preventDefault();
            alert('Thank you for joining our waitlist! We\'ll notify you when the course becomes available.');
            modal.style.display = 'none';
            form.reset();
        });
