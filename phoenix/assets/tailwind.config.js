/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./css/app.css",
    "./css/phoenix.css"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/aspect-ratio"),
  ],
}
