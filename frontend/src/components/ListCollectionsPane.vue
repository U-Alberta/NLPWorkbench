<template>
  <el-table v-loading="loading" :data="collections" style="width: 100%">
    <el-table-column sortable prop="name" label="Name" width="100" />
    <el-table-column sortable prop="creation_date" label="Created At" width="180" :formatter="formatDateRow"/>
    <el-table-column sortable prop="docs" label="Documents" width="130" />
    <el-table-column prop="description" label="Description" />
    <el-table-column fixed="right" width="120">
      <template #default="scope">
        <el-tooltip
            content="show logs"
            placement="bottom">
          <el-button size="small" @click="showLogs(scope.$index, scope.row)">
            <el-icon>
              <View />
            </el-icon>
          </el-button>
        </el-tooltip>
        <el-button size="small" type="danger" @click="this.selectedName = scope.row.name; this.deleteDialogInput = ''; this.deleteDialogOpen = true">
          <el-icon>
            <Delete />
          </el-icon>
        </el-button>
      </template>
    </el-table-column>
  </el-table>
  <!-- Delete Confirmation Dialog -->
  <el-dialog
      v-model="deleteDialogOpen"
      title="Confirm deletion"
      width="50%"
  >
    <span style="hyphens: auto; word-break: normal;">Are you sure to delete the collection?
      All documents stored in the collection will be deleted.
      This operation can not be reversed. Type in the exact collection name </span>
      <code>{{selectedName}}</code> <span> to confirm.
    </span>
    <el-input style="margin-top: 10px" v-model="deleteDialogInput"></el-input>
    <template #footer>
            <span class="dialog-footer">
              <el-button @click="deleteDialogOpen = false">Cancel</el-button>
              <el-button
                  type="danger"
                  :loading="deleteLoading"
                  :disabled="deleteLoading || selectedName !== deleteDialogInput"
                  @click="handleDelete()">
                Confirm
              </el-button>
            </span>
    </template>
  </el-dialog>
  <!-- END OF Delete Confirmation Dialog -->
  <!-- View Log Dialog -->
  <el-dialog
      v-model="logDialogOpen"
      title="Operation Log"
      width="50%"
  >
    <el-timeline v-loading="logLoading">
      <el-timeline-item
        v-for="(logItem, index) in collectionLog"
        :key="index"
        :timestamp="formatDateTime(logItem.time * 1000)"
      >
        <el-descriptions :title="logItem.operation">
          <el-descriptions-item
              v-for="key in Object.keys(logItem).filter((x) => x !== 'operation' && x !== 'time' && logItem[x])"
              :label="key.replaceAll('_', ' ')"
              >
            {{logItem[key]}}
          </el-descriptions-item>
        </el-descriptions>
      </el-timeline-item>
    </el-timeline>
  </el-dialog>
  <!-- END OF View Log Dialog -->
</template>

<script>
import axios from "axios";

export default {
  name: "ListCollectionsPane",
  emits: ["errorMsg", "successMsg"],
  data() {
    return {
      loading: false,
      collections: [],
      deleteDialogOpen: false,
      deleteDialogInput: "",
      selectedName: "",
      deleteLoading: false,
      logDialogOpen: false,
      logLoading: false,
      collectionLog:
        [
          {
            "description": "",
            "operation": "create",
            "time": 1681927946.616219
          },
          {
            "imported_docs": 10,
            "operation": "update",
            "source": "LocalFile",
            "time": 1681927959.934908
          },
          {
            "imported_docs": 4,
            "operation": "update",
            "source": "News Search",
            "time": 1681928652.608348
          }
        ]
    }
  },
  methods: {
    formatDateRow(row) {
      return this.formatDateTime(Number.parseInt(row.creation_date))
    },
    formatDateTime(timestamp) {
      const date = new Date(timestamp)
      return date.toLocaleString()
    },
    showLogs(index, row) {
      this.selectedName = row.name
      this.collectionLog = null
      this.logDialogOpen = true
      this.logLoading = true
      axios.post(`${this.api}/snc/getlog`, {"es_index_name": this.selectedName}).then((resp) => {
        this.collectionLog = resp.data.reverse()
      }).catch((e) => {
        this.$emit("errorMsg", e)
        this.logDialogOpen = false
      }).then(() => {
        this.logLoading = false
      })
    },
    handleDelete() {
      this.deleteLoading = true
      axios.delete(`${this.api}/snc/indexes/${this.selectedName}`).then((resp) => {
        this.$emit("successMsg", "Collection deleted.")
        this.refreshList()
      }).catch((e) => {
        this.$emit("errorMsg", e)
      }).then(() => {
        this.deleteLoading = false
        this.deleteDialogOpen = false
      })
    },
    refreshList() {
      this.loading = true
      axios.get(`${this.api}/snc/indexes?detailed`).then((resp) => {
        this.collections = resp.data
      }).catch((e) => {
        console.log(e)
        this.$emit("errorMsg", e)
      }).then(() => {
        this.loading = false
      })
    }
  },
  mounted() {
    this.refreshList()
  }
}
</script>

<style scoped>

</style>