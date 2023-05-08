<template>
  <el-steps :active="currentStep" finish-status="success" :space="300">
    <el-step title="Build Query"/>
    <el-step title="Preview Documents"/>
    <el-step title="Submit Tasks"/>
  </el-steps>

  <!-- build query -->
  <div v-if="currentStep===0" style="margin-top: 20px">
    <el-form :model="queryForm" label-width="140px">
      <el-form-item label="Index name">
        <el-input v-model="queryForm.index"/>
      </el-form-item>
      <el-form-item label="Do not re-compute">
        <el-checkbox-group v-model="queryForm.exclude">
          <el-checkbox label="NER"/>
          <el-checkbox label="Linker"/>
          <el-checkbox label="AMR Parsing"/>
          <el-checkbox label="Person Relation Extraction"/>
          <el-checkbox label="Sentiment Analysis"/>
          <el-checkbox label="Relation Extraction"/>
        </el-checkbox-group>
      </el-form-item>
      <el-form-item label="KQL">
        <el-input v-model="queryForm.kql" type="textarea"/>
        <el-link type="info" href="https://www.elastic.co/guide/en/kibana/current/kuery-query.html" target="_blank">
          What's KQL?
        </el-link>
      </el-form-item>
      <el-form-item label="Final query">
        <el-input v-model="esQueryFormatted" type="textarea" :disabled="true" autosize/>
      </el-form-item>
    </el-form>
  </div>
  <!-- preview results -->
  <div v-if="currentStep===1" style="margin-top: 20px">
    <DocBrowsingTable
        @errorMsg="(x) => $.emit('errorMsg', x)"
        @successMsg="(x)=>$.emit('successMsg', x)"
        :es-query="esQuery"
        :index="queryForm.index"
    />
  </div>
  <!-- submit jobs -->
  <div v-if="currentStep===2" style="margin-top: 20px">
    <div>
      Number of documents: {{ preview.total }}
    </div>
    <el-form>
      <el-form-item label="Tasks to perform">
        <el-checkbox-group v-model="tasksToDo">
          <el-checkbox label="NER"/>
          <el-checkbox label="Linker"/>
          <el-checkbox label="AMR Parsing"/>
          <el-checkbox label="Person Relation Extraction"/>
          <el-checkbox label="Sentiment Analysis"/>
          <el-checkbox label="Relation Extraction"/>
        </el-checkbox-group>
      </el-form-item>
      <el-button type="primary" :disabled="tasksToDo.length === 0 || submitLoading" :loading="submitLoading"
                 @click="submit">Submit
      </el-button>
    </el-form>
  </div>

  <el-row style="margin-top:20px">
    <el-button :disabled="currentStep === 0" @click="currentStep -= 1">
      <el-icon>
        <ArrowLeft/>
        ️
      </el-icon>&nbsp; Previous Step
    </el-button>
    <el-button :disabled="currentStep === 2" @click="currentStep += 1">Next Step&nbsp;<el-icon>
      <ArrowRight/>
      ️
    </el-icon>
    </el-button>
  </el-row>
</template>

<script>
import axios from 'axios'
import { buildEsQuery } from "@cybernetex/kbn-es-query";
import { fixAuthor } from '~/common'
import DocBrowsingTable from "~/components/DocBrowsingTable.vue";

export default {
  name: "BatchModePane",
  components: {DocBrowsingTable},
  emits: ["errorMsg", "successMsg"],
  data() {
    return {
      currentStep: 0,
      queryForm: {
        index: "bloomberg-reuters-v1", // TODO: select from dropdown list
        exclude: [],
        kql: "",
      },
      tasksToDo: [],
      submitLoading: false
    }
  },
  computed: {
    esQuery: function() {
      if (this.queryForm.kql.trim() === "" && this.queryForm.exclude.length === 0) {
        return {
          match_all: {}
        }
      }

      const esCacheFields = new Map([
        ["NER", "raw-ner-output"],
        ["Linker", "raw-linker-output"],
        ["AMR Parsing", "raw-amr-output"],
        ["Person Relation Extraction", "raw-person-rel-output"],
        ["Sentiment Analysis", "vader-output"],
        ["Relation Extraction", "re-output"]
      ]);

      const dsl = buildEsQuery(undefined, {language: "kuery", query: this.queryForm.kql})
      this.queryForm.exclude.forEach((v) => {
        dsl.bool.must_not.push({exists: {field: esCacheFields.get(v)}})
      })
      return dsl
    },
    esQueryFormatted: function() {
      return JSON.stringify(this.esQuery, null, 2)
    }
  },
  watch: {
    currentStep(newStep, oldStep) {
      this.$emit("errorMsg", "")
      if (oldStep === 0) {
        this.successMsg = ""
        this.previewPage = 1
        this.preview = {
          total: 0,
          hits: []
        }
      }
    },
  },
  methods: {
    submit: function () {
      const taskNames = new Map([
        ["NER", "ner"],
        ["Linker", "linker"],
        ["AMR Parsing", "amr"],
        ["Person Relation Extraction", "person_rel"],
        ["Sentiment Analysis", "sentiment"],
        ["Relation Extraction", "relation"]
      ]);
      const tasks = this.tasksToDo.map((x) => taskNames.get(x))
      const req = {
        index: this.queryForm.index,
        query: this.esQuery,
        tasks: tasks,
      }
      this.submitLoading = true

      const that = this
      axios.post(`${this.api}/admin/batch`, req).then((resp) => {
        const successMsg = `${resp.data.num_tasks} total task(s) submitted for ${resp.data.num_docs} document(s).`
        that.$emit("successMsg", successMsg)
        that.currentStep = 0
      }).catch((e) => {
        console.log(e)
        that.$emit("errorMsg", e)
      }).then(() => {
        that.submitLoading = false
      })
    },
    openLink: function (link) {
      window.open(link, '_blank').focus()
    },
  }
}
</script>

<style scoped>

</style>