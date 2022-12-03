<template>
  <el-button
      style="margin-top: 20px"
      type="primary"
      @click="onClickAMR"
      :loading="amrLoading"
      :disabled="newsId !== newsIdInput">
    {{newsId === newsIdInput ? 'Run Semantic Parsing' : 'Reload news first'}}
  </el-button>
  <div v-if="amrOutput">
    <h4 style="text-align: left">AMR Parsing Output</h4>
    <el-collapse v-model="activeGraph" accordion>
      <el-collapse-item v-for="(item, idx) in amrOutput" :title="item.shortenSent" :name="idx">
        <div>{{item.sentence}}</div>
        <v-network-graph
            v-if="activeGraph === idx"
            :nodes="item.nodes"
            :edges="item.edges"
            :configs="graphConfigs"
            class="graph">
          <template #edge-label="{ edge, ...slotProps }">
            <v-edge-label :text="edge.relationship" align="center" vertical-align="above" v-bind="slotProps" />
          </template>
        </v-network-graph>
      </el-collapse-item>
    </el-collapse>
  </div>
</template>

<script>
import axios from "axios";
import {
  ForceLayout
} from "v-network-graph/lib/force-layout"

export default {
  name: "SemanticParsingPane",
  emits: ["errorMsg"],
  props: ["newsId", "newsIdInput", "collection"],
  data() {
    return {
      activeGraph: "0",
      amrOutput: null,
      amrLoading: false,
      graphConfigs: {
        view: {
          layoutHandler: new ForceLayout()
        },
        node: {
          label: {
            text: "label"
          },
          normal: {
            color: node => {
              if (node.name === "z0") return "#FAFCCD"
              else if (node.name[0] === "z") return "#C0DDEB"
              else return "#FFFFFF00"
            },
            radius: node => {
              if (node.name[0] === "c") return 2
              else return 16
            },
            strokeWidth: node => {
              if (node.name === "z0") return 2
              else if (node.name[0] === "z") return 1
              else return 0
            },
          }
        },
        edge: {
          normal: {
            color: "#606060",
            width: edge => {
              if (/ARG\d+/.test(edge.relationship)) {
                return 2
              } else {
                return 1
              }
            }
          },
          marker: {
            target: {
              type: "arrow"
            }
          }
        }
      }
    }
  },
  watch: {
    newsId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.amrOutput = null
        this.amrLoading = false
      }
    }
  },
  methods: {
    onClickAMR() {
      this.amrOutput = null
      this.amrLoading = true

      this.$emit("errorMsg", "")
      let that = this
      axios.get(
          `${this.api}/semantic/${this.newsId}`,
          {params: {collection: this.collection}}
      ).then((resp) => {
        that.amrOutput = resp.data.map (data => {
          let nodes = {}
          let edges = {}
          data.nodes.forEach(node => {
            nodes[node.name] = node
            if (node.name[0] === "c") {
              if (typeof node.value === 'string' || node.value instanceof String) {
                node.label = '"' + node.value + '"'
              } else {
                node.label = String(node.value)
              }
            } else {
              node.label = `${node.name} / ${node.concept}`
            }
          })

          data.edges.forEach((edge, index) => {
            edges[`edge${index}`] = {
              source: edge.var1,
              target: edge.var2,
              relationship: edge.relationship
            }
          })
          return {
            sentence: data.sentence,
            shortenSent: data.sentence.length > 80 ? data.sentence.slice(0, 80) + "..." : data.sentence,
            nodes: nodes,
            edges: edges
          }
        })
      }).catch(error => {
        that.$emit("errorMsg", error)
      }).then(() => {
        this.amrLoading = false
      })

    }
  }
}
</script>

<style scoped>
.graph {
  height: 300px !important;
  width: auto !important;
  border: #c0ccda 1px solid;
}
</style>