<template>
  <div v-if="outputs" style="display: flex; justify-content: center">
    <el-table :data="outputs" style="width: 98%">
      <el-table-column label="Classifier" prop="name" :width="125"/>
      <el-table-column label="Predictions">
        <template #default="scope">
          <el-tag size="small" style="margin-right: 3px" v-for="x in scope.row.predictions"> {{x}} </el-tag>
        </template>
      </el-table-column>
    </el-table>
  </div>
  <div v-if="loading || sentimentLoading" v-loading="loading || sentimentLoading" style="height: 40px"/> <!-- loading placeholder -->
</template>

<script>
import axios from "axios";

export default {
  name: "ClassifierTab",
  props: ["documentId", "collection"],
  emits: ["errorMsg"],
  data() {
    return {
      loading: false,
      sentimentLoading: false,
      outputs: [],
    }
  },
  watch: {
    documentId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.outputs = []
        this.loading = false
        this.sentimentLoading = false
        this.runTool()
      }
    }
  },
  methods: {
    runTool() {
      this.loading = true
      this.outputs = []

      this.runSentimentAnalysis()

      this.$emit("errorMsg", "")

      axios.get(
          `${this.api}/collection/${this.collection}/doc/${this.documentId}/classify`,
      ).then((resp) => {
        this.outputs = this.outputs.concat([
          {name: "Crime (SVM)", predictions: resp.data.multiclass_prediction},
          {name: "Crime (1 vs N)", predictions: resp.data.multiclass_OneVsRest_prediction},
          {name: "Crime (BERT)", predictions: resp.data.multilabel_bert_prediction},
          {name: "Crime (finBERT)", predictions: resp.data.multilabel_finbert_prediction},
        ])
        this.outputs.sort((a, b) => a.name >= b.name ? 1 : -1)
      }).catch((err) => {
        this.$emit("errorMsg", err)
        console.log(err)
      }).then(() => {
        this.loading = false
      })
    },
    runSentimentAnalysis() {
      /*
      We are integrating sentiment analysis into classifiers.
      So far, this is done in the frontend by treating SA as a special case.
      In the future, we hope to do this integration in the backend.
       */
      this.outputs = this.outputs.filter(x => x.name !== "Sentiment")
      this.sentimentLoading = true

      this.$emit("errorMsg", "")

      axios.get(
          `${this.api}/collection/${this.collection}/doc/${this.documentId}/sentiment`,
      ).then((resp) => {
        const score = resp.data.polarity_compound
        let label = "Negative"
        if (score > -0.05 && score < 0.05) {
          label = "Neutral"
        } else if (score >= 0.05) {
          label = "Positive"
        }
        this.outputs = this.outputs.filter(x => x.name !== "Sentiment")
        this.outputs.push({name: "Sentiment", predictions: [label], details: `Polarity Compound: ${score}`})
        this.outputs.sort((a, b) => a.name >= b.name ? 1 : -1)
        console.log(resp.data)
      }).catch((err) => {
        this.$emit("errorMsg", err)
        console.log(err)
      }).then(() => {
        this.sentimentLoading = false
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
.slider {
  width: 70%;
  margin: 30px auto auto;
}
</style>