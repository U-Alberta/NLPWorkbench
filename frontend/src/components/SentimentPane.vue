<template>
  <div>
    <el-button
        style="margin-top: 20px"
        type="primary"
        @click="onClickRun"
        :loading="loading"
        :disabled="newsId !== newsIdInput">
      {{newsId === newsIdInput ? 'Run Sentiment Analysis' : 'Reload News First'}}
    </el-button>
    <el-slider v-if="outputs !== null && !loading" class="slider" v-model="outputs.polarity_compound" disabled :min="-1" :max="1" :marks="marks"/>
  </div>


</template>

<script>
import axios from "axios";

export default {
  name: "SentimentPane",
  props: ["newsId", "newsIdInput", "collection"],
  emits: ["errorMsg"],
  data() {
    return {
      loading: false,
      outputs: null,
      mockValue: 0.2,
      marks: {
        "-1": "Negative",
        "-0.05": "",
        "0": "Neutral",
        "0.05": "",
        "1": "Positive"
      }
    }
  },
  watch: {
    newsId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.outputs = null
        this.loading = false
      }
    }
  },
  methods: {
    onClickRun() {
      this.outputs = null
      this.loading = true

      this.$emit("errorMsg", "")

      let that = this
      axios.get(
          `${this.api}/sentiment/${this.newsId}`,
          {params: {collection: this.collection}}
      ).then((resp) => {
        that.outputs = resp.data
        console.log(resp.data)
      }).catch((err) => {
        that.$emit("errorMsg", err)
        console.log(err)
      }).then(() => {
        that.loading = false
      })
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