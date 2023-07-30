<template>
  <div v-loading="reLoading">
    <div v-for="(re, index) in reOutput" style="text-align: left">
      <el-popover trigger="hover" :width="300">
        <template #reference>
          <span><b>Relation {{ index + 1 }}</b>: {{ re.subject }} -- {{ re.predicate }} -- {{ re.object }}</span>
        </template>
        <div class="popover">
          <b>Source:</b> {{re.sents ? re.sents[0] : ""}}
        </div>
      </el-popover>
      <br />
    </div>
    <el-empty v-if="reOutput && reOutput.length === 0" description="No relations." :image-size="80"></el-empty>
  </div>
</template>
  
<script>
import axios from "axios";

export default {
  name: "RelationTab",
  emits: ["errorMsg"],
  props: ["documentId", "collection"],
  data() {
    return {
      reLoading: false,
      reOutput: null,
    }
  },
  watch: {
    documentId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.reOutput = null
        this.reLoading = false
        this.runTool()
      }
    }
  },
  methods: {
    runTool() {
      this.$emit("errorMsg", "")
      this.reLoading = true
      this.reOutput = [
        {subject: "Entity 1", predicate: "Related To", object: "Entity 2"},
        {subject: "Entity 2", predicate: "Related To", object: "Entity 3"},
        {subject: "Entity 3", predicate: "Related To", object: "Entity 4"},
        {subject: "Entity 4", predicate: "Related To", object: "Entity 5"},
        {subject: "Entity 5", predicate: "Related To", object: "Entity 6"},
      ]
      let that = this
      axios.get(
        `${this.api}/collection/${this.collection}/doc/${this.documentId}/relation`
      ).then((response) => {
        response.data.forEach((x) => {
          if (x.predicate === 'PER-SOC') {
            x.predicate = "Person-Social (e.g. family)"
          } else if (x.predicate === 'PHYS') {
            x.predicate = "Physical (e.g. near)"
          } else if (x.predicate === 'ORG-AFF') {
            x.predicate = 'Organization-Affiliation (e.g. employment)'
          } else if (x.predicate === 'ART') {
            x.predicate = 'Agent-Artifact (e.g. owner and object)'
          } else if (x.predicate === 'GEN-AFF') {
            x.predicate = 'General-Affiliation (e.g. citizen)'
          }
        })
        that.reOutput = response.data
        that.redocumentId = that.documentId
      }).catch(err => {
        console.log(err)
        that.$emit("errorMsg", err.message)
        that.reOutput = []
      }).then(() => {
        that.reLoading = false
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