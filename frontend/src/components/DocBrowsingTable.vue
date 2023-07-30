<template>
  <div>
    <div v-if="!asSelector">
      Matched documents: {{ preview.gte ? '&ge;' : '' }}{{ preview.total }}
    </div>
    <el-table
        v-if="!(asSelector && preview.hits.length === 0)"
        :data="preview.hits"
        v-loading="previewLoading"
        :highlight-current-row="asSelector"
        v-el-table-infinite-scroll="loadMore"
        :height="tableHeight"
        @row-click="onRowClick"
        row-key="index"
        :current-row-key="tableCurrentRow"
    >
      <el-table-column type="expand" v-if="!asSelector">
        <template #default="props">
          <div>{{ props.row.fields.content[0] }}</div>
        </template>
      </el-table-column>
      <el-table-column type="index" v-if="asSelector"/>
      <el-table-column prop="id" label="ID" width="100" :show-overflow-tooltip="true"/>
      <el-table-column prop="fields.author" label="Author" :show-overflow-tooltip="true" v-if="!asSelector"/>
      <el-table-column prop="fields.title" label="Title" min-width="180" :show-overflow-tooltip="asSelector"/>
      <!-- Jump to document not implemented -->
      <!--
      <el-table-column fixed="right" width="60" v-if="!asSelector">
        <template #default="scope">
          <el-tooltip
              content="Run analysis tools"
              placement="bottom">
            <el-button size="small" @click="openDoc(scope.row)">
              <el-icon>
                <MagicStick/>
              </el-icon>
            </el-button>
          </el-tooltip>
        </template>
      </el-table-column>
    -->
    </el-table>
    <el-pagination v-if="!infScroll" layout="prev, pager, next" :total="preview.total"
                   v-model:current-page="previewPage"/>
  </div>
</template>

<script>
import axios from "axios";
import {fixAuthor} from "~/common";
import {MagicStick} from "@element-plus/icons-vue";

export default {
  name: "DocBrowsingTable",
  components: {MagicStick},
  props: {
    esQuery: Object,
    index: String,
    infScroll: {
      default: false
    },
    asSelector: {
      /*
      * Whether to use this component to select a document.
      * If `true`, document content and buttons will not be shown;
      * each row is selectable.
      */
      default: false
    },
    pageSize: {
      default: 10
    },
    tableHeight: {
      default: "auto"
    },
    selectedRowIndex: {
      default: null
    }
  },
  emits: ["errorMsg", "successMsg", "docSelected", "docsLoaded"],
  data() {
    return {
      preview: {
        total: 0,
        hits: []
      },
      previewLoading: false,
      previewPage: 1,
      tableCurrentRow: 0
    }
  },
  methods: {
    loadMore: function () {
      if (!this.infScroll) return
      if (this.previewPage * this.pageSize > this.preview.total) return // FIXME: won't work if total is too large
      this.previewPage += 1
    },
    loadPreview: function () {
      if (!this.index || !this.esQuery) {
        return
      }
      const req = {
        query: this.esQuery,
        skip: (this.previewPage - 1) * this.pageSize,
        size: this.pageSize
      }
      /* might temper with pager
      this.preview = {
        total: 0,
        hits: []
      }
       */
      this.previewLoading = true

      axios.post(`${this.api}/collection/${this.index}/preview`, req).then((resp) => {
        let hits = resp.data.hits
        hits.forEach((value) => {
          let authorStr = value.fields.author[0]
          value.fields.author = fixAuthor(authorStr)
          if (!value.fields.title) {
            value.fields.title = "Untitled Document"
          }
        })
        if (this.infScroll && this.previewPage > 1) {
          this.preview.total = resp.data.total
          resp.data.hits.forEach((value, index) => value.index = index + this.preview.hits.length)
          this.preview.hits = this.preview.hits.concat(resp.data.hits)

          if (this.selectedRowIndex !== this.tableCurrentRow && this.selectedRowIndex < this.preview.hits.length) {
            // tried to select a row in the next page, and data for next page are loaded
            this.tableCurrentRow = this.selectedRowIndex
            this.$emit("docSelected", this.preview.hits[this.selectedRowIndex])
          }
        } else {
          resp.data.hits.forEach((value, index) => value.index = index)
          this.preview = resp.data
        }
        this.$emit("docsLoaded", this.preview.hits.length)
      }).catch((e) => {
        console.error(e)
        this.$emit("errorMsg", e)
        this.preview = {
          total: 0,
          hits: []
        }
      }).then(() => {
        this.previewLoading = false
      })
    },
    onRowClick: function (row) {
      this.$emit("docSelected", row)
    },
    reset: function () {
      this.previewPage = 1
      this.preview = {
        total: 0,
        hits: []
      }
      this.tableCurrentRow = 0
      this.loadPreview()
    }
  },
  watch: {
    esQuery() {
      this.reset()
    },
    index() {
      this.reset()
    },
    previewPage(newPage, oldPage) {
      this.loadPreview()
    },
    selectedRowIndex(newRowIndex) {
      if (newRowIndex === null) return
      if (newRowIndex < 0) {
        newRowIndex = 0
      } else if (newRowIndex >= this.preview.total) {
        newRowIndex = this.preview.total - 1
      }
      if (newRowIndex < this.preview.hits.length) {
        // row already exists, can direct select new row
        this.tableCurrentRow = newRowIndex
        console.log("setting current row to", this.tableCurrentRow)
        this.$emit("docSelected", this.preview.hits[newRowIndex])
      } else {
        // more data need to be loaded
        this.loadMore()
      }
    }
  },
  mounted() {
    this.loadPreview()
  }
}
</script>

<style scoped>

</style>