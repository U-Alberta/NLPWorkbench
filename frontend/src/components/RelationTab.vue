<template>
  <div>
    <el-button style="margin-top: 20px" type="primary" @click="onClickRun" :loading="reLoading"
      :disabled="newsId !== newsIdInput">
      {{ newsId === newsIdInput ? 'Run Relation Extraction' : 'Reload News First' }}
    </el-button>
    <div v-if="reOutput" style="margin-top: 40px">
      <div v-for="(re, index) in reOutput" style="text-align: left">
        <span><b>Relation {{ index + 1 }}</b>: {{ re.subject }} -- {{ re.predicate }} -- {{ re.object }}</span>
        <br />
        <i class="evidence">Score: {{re.score.toFixed(2)}}</i>
        <br />
        <i class="evidence" v-for="(sent, sent_i) in re.sents">Evidence {{sent_i + 1}}: {{ sent }}<br /></i>
        <el-divider v-if="index !== reOutput.length - 1" />
      </div>
    </div>
  </div>
</template>
  
<script>
import axios from "axios";

export default {
  name: "RelationTab",
  emits: ["errorMsg"],
  props: ["newsId", "newsIdInput", "collection"],
  data() {
    return {
      reLoading: false,
      reOutput: null,
    }
  },
  watch: {
    newsId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.reOutput = null
        this.reLoading = false
      }
    }
  },
  methods: {
    onClickRun() {
      this.$emit("errorMsg", "")
      this.reLoading = true
      this.reOutput = null
      this.reNewsId = null
      let that = this
      axios.get(
        `${this.api}/relation/${this.newsId}`,
        {params: {collection: this.collection}}
      ).then((response) => {
        that.reOutput = response.data
        that.reNewsId = that.newsId
      }).catch(err => {
        console.log(err)
        that.$emit("errorMsg", err.message)
        that.reOutput = null
      }).then(() => {
        that.reLoading = false
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