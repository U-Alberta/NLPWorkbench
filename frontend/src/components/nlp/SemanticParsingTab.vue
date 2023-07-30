<template>
  <div v-if="amrOutput" style="width: 100%; display: flex; justify-content: center">
    <el-collapse v-model="activeGraph" accordion style="width: 92%; padding: 10px 10px 10px 10px; border: #ccc dashed 1px">
      <el-collapse-item v-for="(item, idx) in amrOutput" :name="idx">
        <template #title>
          <div class="amr-sent">
            {{item.shortenSent}}
          </div>
        </template>
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
  <div v-if="amrLoading" v-loading="true" style="height: 50px" />
</template>

<script>
import axios from "axios";
import {
  ForceLayout
} from "v-network-graph/lib/force-layout"

export default {
  name: "SemanticParsingTab",
  emits: ["errorMsg"],
  props: ["documentId", "collection"],
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
    documentId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.amrOutput = null
        this.amrLoading = false
        this.runTool()
      }
    }
  },
  methods: {
    runTool() {
      this.amrOutput = null
      this.amrLoading = true

      this.$emit("errorMsg", "")
      let that = this
      axios.get(
          `${this.api}/collection/${this.collection}/doc/${this.documentId}/semantic`
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
  },
  mounted() {
    if (this.collection && this.documentId) {
      this.runTool()
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

.amr-sent {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-style: italic;
  font-weight: lighter;
}
</style>