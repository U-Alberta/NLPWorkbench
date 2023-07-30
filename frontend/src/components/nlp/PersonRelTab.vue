<template>
  <div v-if="relOutputs" v-loading="relLoading">
    <div v-for="(rel, index) in relOutputs" style="text-align: left">
      <el-popover trigger="hover" :width="300">
        <template #reference>
          <span><b>Relation {{ index + 1 }}</b>: {{ rel.rel_text }}</span>
        </template>
        <div class="popover">
          <b>Source:</b> {{rel.sent}}
        </div>
      </el-popover>
      <br/>
    </div>
  </div>
  <el-empty v-if="relOutputs && relOutputs.length === 0" description="No relations." :image-size="80"></el-empty>
</template>

<script>
import axios from "axios";

export default {
  name: "PersonRelTab",
  props: ["documentId", "collection"],
  emits: ["errorMsg"],
  data() {
    return {
      relLoading: false,
      relOutputs: null
    }
  },
  watch: {
    documentId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.relOutputs = null
        this.relLoading = false
        this.runTool()
      }
    }
  },
  methods: {
    runTool() {
      this.relLoading = true
      this.relOutputs = [
        {rel_text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", sent: "Vivamus accumsan ornare mattis."},
        {rel_text: "Cras dapibus nec nunc ut sollicitudin.", sent: "Donec nec dictum ante."},
      ]

      this.$emit("errorMsg", "")

      axios.get(
          `${this.api}/collection/${this.collection}/doc/${this.documentId}/person_relation`
      ).then((resp) => {
        this.relOutputs = resp.data
      }).catch((err) => {
        this.$emit("errorMsg", err)
        this.relOutputs = []
        console.error(err)
      }).then(() => {
        this.relLoading = false
      })
    }
  },
  mounted() {
    if (this.documentId && this.collection) {
      this.runTool()
    }
  }
}
</script>

<style scoped>
.popover {
  font-family: var(--el-font-family);
  word-break: inherit;
  color: #2e4052;
}
</style>