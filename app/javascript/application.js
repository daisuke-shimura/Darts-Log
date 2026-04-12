// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
  if (document.body.dataset.page === "records") {
    document.querySelectorAll("a").forEach(link => {
      link.addEventListener("click", (e) => {
        if (!confirm("離れるとログアウトします。よろしいですか？")) {
          e.preventDefault();
        }
      });
    });
  }
});
