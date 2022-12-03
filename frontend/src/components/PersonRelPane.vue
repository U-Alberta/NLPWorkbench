<template>
  <el-button
      style="margin-top: 20px"
      type="primary"
      @click="onClickRun"
      :loading="relLoading"
      :disabled="newsId !== newsIdInput">
    {{ newsId === newsIdInput ? 'Run Person Relation Extraction' : 'Reload News First' }}
  </el-button>
  <div v-if="relOutputs" style="margin-top: 40px">
    <div v-for="(rel, index) in relOutputs" style="text-align: left">
      <span><b>Relation {{ index + 1 }}</b>: {{ rel.rel_text }}</span>
      <br/>
      <i class="evidence">Evidence: {{ rel.sent }}</i>
      <el-divider v-if="index !== relOutputs.length - 1"/>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "PersonRelPane",
  props: ["newsId", "newsIdInput", "collection"],
  emits: ["errorMsg"],
  data() {
    return {
      relLoading: false,
      relOutputs: null
    }
  },
  watch: {
    newsId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.relOutputs = null
        this.relLoading = false
      }
    }
  },
  methods: {
    onClickRun() {
      this.relOutputs = null
      this.relLoading = true

      this.$emit("errorMsg", "")

      let that = this
      axios.get(
          `${this.api}/person_relations/${this.newsId}`,
          {params: {collection: this.collection}}
      ).then((resp) => {
        that.relOutputs = resp.data
      }).catch((err) => {
        that.$emit("errorMsg", err)
        console.log(err)
      }).then(() => {
        that.relLoading = false
      })
    }
  }
}
</script>

<style scoped>
.evidence {
  font-size: small;
  color: #2e4052;
}
</style>