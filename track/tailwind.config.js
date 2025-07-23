// プロジェクトのルートに配置
module.exports = {
  content: [
    './app/views/**/*.{erb,haml,html,slim}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,ts,jsx,tsx}',
  ],
  safelist: ['hidden'], // 任意（動的に使うなら必須）
  theme: {
    extend: {},
  },
  plugins: [],
}
