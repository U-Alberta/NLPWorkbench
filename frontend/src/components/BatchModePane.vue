<template>
  <el-steps :active="currentStep" finish-status="success" :space="300">
    <el-step title="Build Query"/>
    <el-step title="Preview Documents"/>
    <el-step title="Submit Tasks"/>
  </el-steps>

  <!-- build query -->
  <div v-if="currentStep===0" style="margin-top: 20px">
    <el-form :model="queryForm" label-width="140px">
      <el-form-item label="Collection" prop="collection">
        <el-select v-model="queryForm.collection" filterable placeholder="Select" :loading="collectionListLoading" loading-text="Loading...">
          <el-option
              v-for="item in collections"
              :key="item"
              :label="item"
              :value="item"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="Do not re-compute">
        <el-checkbox-group v-model="queryForm.exclude">
          <el-checkbox label="NER"/>
          <el-checkbox label="Linker"/>
          <el-checkbox label="AMR Parsing"/>
          <el-checkbox label="Person Relation Extraction"/>
          <el-checkbox label="Sentiment Analysis"/>
          <el-checkbox label="Relation Extraction"/>
          <el-checkbox label="Crime Classification"/>
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
        :index="queryForm.collection"
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
          <el-checkbox label="Crime Classification"/>
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
        <arrow-left />
      </el-icon>&nbsp; Previous Step
    </el-button>
    <el-button :disabled="currentStep === 2 || queryForm.collection.trim() === ''" @click="currentStep += 1">Next Step&nbsp;<el-icon>
      <arrow-right />
    </el-icon>
    </el-button>
  </el-row>
</template>

<script>
import axios from 'axios'
import { buildEsQuery } from "@cybernetex/kbn-es-query";
import DocBrowsingTable from "~/components/DocBrowsingTable.vue";
import {ArrowLeft, ArrowRight} from "@element-plus/icons-vue";

export default {
  name: "BatchModePane",
  components: {ArrowRight, ArrowLeft, DocBrowsingTable},
  emits: ["errorMsg", "successMsg"],
  data() {
    return {
      currentStep: 0,
      queryForm: {
        collection: "",
        exclude: [],
        kql: "",
      },
      collections: [],
      collectionListLoading: false,
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
        ["Relation Extraction", "re-output-v2"],
        ["Crime Classification", "crime-classifier-output.multiclass_prediction"],
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
        ["Relation Extraction", "relation"],
        ["Crime Classification", "classify"],
      ]);
      const tasks = this.tasksToDo.map((x) => taskNames.get(x))
      const req = {
        query: this.esQuery,
        tasks: tasks,
      }
      this.submitLoading = true

      const that = this
      axios.post(`${this.api}/collection/${this.queryForm.collection}/batch`, req).then((resp) => {
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
  },
  mounted() {
    this.collectionListLoading = true
    axios.get(`${this.api}/collection/`).then((resp) => {
      this.collections = resp.data
    }).catch((e) => {
      console.log(e)
      this.$emit("errorMsg", e)
    }).then(() => {
      this.collectionListLoading = false
    })
  }
}
</script>

<style scoped>

</style>