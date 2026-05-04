// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// ログイン時のフラッシュメッセージ
document.addEventListener("turbo:load", () => {
  const toastElList = document.querySelectorAll(".login-toast");
  toastElList.forEach((toastEl) => {
    new bootstrap.Toast(toastEl).show();
  });
});
