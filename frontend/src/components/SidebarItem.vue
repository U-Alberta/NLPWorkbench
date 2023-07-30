<template>
  <el-collapse-item :name="name">
    <template #title>
      <!-- Note for future developers -->
      <!-- To have fullscreen working, the tab needs to be implemented in FullscreenApp.vue as well -->
      <div class="tab-title-expandable">
        {{title}}
        <el-link v-if="viewableInFullscreen"
                 class="expand-icon"
                 title="Open in new window"
                 :underline="false"
                 @click.stop="openNewWindow(name, title)">
          <el-icon class="header-icon">
            <full-screen/>
          </el-icon>
        </el-link>
      </div>
    </template>
    <slot></slot>
  </el-collapse-item>
</template>

<script>
import {FullScreen} from "@element-plus/icons-vue";
import {defineComponent} from 'vue'

export default defineComponent({
  name: "SidebarItem",
  props: {
    name: String,
    title: String,
    documentId: String,
    collection: String,
    viewableInFullscreen: Boolean
  },
  components: {FullScreen},
  methods: {
    openNewWindow(view, title) {
      const params = new URLSearchParams()
      params.append("view", view)
      params.append("title", title)
      params.append("documentId", this.documentId)
      params.append("collection", this.collection)
      const url = `/fullscreen/?${params.toString()}`
      window.open(url, '_blank', "popup").focus()
    },
  }
})
</script>

<style scoped>
.tab-title-expandable {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.expand-icon {
  margin-right: 5px;
}
</style>