// @ts-ignore
import path from 'path'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

const pathSrc = path.resolve(__dirname, 'src')

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, "index.html"),
        fullscreen: path.resolve(__dirname, "fullscreen/index.html"),
      }
    }
  },
  resolve: {
    alias: {
      '~/': `${pathSrc}/`,
    },
  },
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: `@use "~/styles/element/index.scss" as *;`,
      },
    },
  },
  plugins: [
    vue(),
  ],
})