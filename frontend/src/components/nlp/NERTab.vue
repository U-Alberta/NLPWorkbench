<template>
  <div style="display: flex; justify-content: end; align-items: center; gap: 5px" >
    <small>Entity Recognition</small>
    <el-switch v-loading="nerEnabled && nerLoading" v-model="nerEnabled" inline-prompt active-text="On" inactive-text="Off"></el-switch>
  </div>
  <div v-loading="nerLoading">
    <div class="sentence" v-for="(sent, sent_idx) in nerOutput">
      <div class="token" v-for="(token, token_idx) in sent">
        <span v-if="typeof token === 'string'">{{ token }}</span>
        <!-- entity -->
        <el-tooltip v-else-if="token.sent_idx !== undefined" effect="dark" placement="top"
                    :content="`Entity - ${token.type}`">
          <a :class="{highlighted: resolvedEntity && resolvedEntity.sent_idx === sent_idx && resolvedEntity.token_idx === token_idx, unresolved: unresolved(sent_idx, token_idx)}"
             :id="`token-${sent_idx}-${token_idx}`"
             :href="unresolved(sent_idx, token_idx) ? null : '#'"
             v-on:click="onClickToken"
             v-on:mouseleave="onLeaveToken"
             v-on:mouseover="onHoverToken">
            {{ token.tokens.join(" ") }}
          </a>
        </el-tooltip>
        <!-- pro-form -->
        <el-tooltip v-else-if="token.entity !== undefined" effect="dark" placement="top"
                    :content="`Pro-form - ${token.type}`">
          <a :id="`token-${sent_idx}-${token_idx}`" :class="{unresolved: unresolved(sent_idx, token_idx)}"
             :href="unresolved(sent_idx, token_idx) ? null : '#'"
             v-on:click="onClickToken"
             v-on:mouseleave="onLeaveToken"
             v-on:mouseover="onHoverToken">
            {{ token.tokens.join(" ") }}</a>
        </el-tooltip>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import LinkerResults from './LinkerResults.vue'

const placeholderText = [
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce varius nunc et orci varius varius." +
  "Fusce bibendum velit eget lacus semper mollis.",
  "Donec eleifend vitae odio quis mattis." +
  "Integer sit amet velit sapien." +
  "Phasellus quis elit vel elit imperdiet congue sed posuere ligula.",
  "Vestibulum ac lacus eu ligula varius fermentum.",
  "Vivamus blandit mollis tellus nec hendrerit." +
  "In sit amet hendrerit nunc." +
  "Aenean faucibus ex vitae lobortis consectetur." +
  "Cras consequat vehicula dolor et consectetur."]

export default {
  name: "NERTab",
  emits: ["errorMsg", "selected"],
  props: ["documentId", "collection"],
  components: {LinkerResults},
  data() {
    return {
      nerEnabled: false,
      nerLoading: false,
      nerOutput: null,
      cachedNERDoc: null,
      cachedDoc: null,
      resolvedEntity: null,
    }
  },
  watch: {
    documentId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.nerOutput = null
        this.cachedDoc = null
        this.cachedNERDoc = null
        this.loadNER()
      }
    },
    nerEnabled() {
      this.loadNER()
    }
  },
  methods: {
    loadNER() {
      this.$emit("errorMsg", "")

      if (this.documentId === null) {
        return
      }

      if (this.nerEnabled && this.cachedNERDoc) {
        this.nerOutput = this.cachedNERDoc
        return
      } else if (!this.nerEnabled && this.cachedDoc) {
        this.nerOutput = this.cachedDoc
      }

      this.nerLoading = true
      if (this.nerOutput === null) {
        this.nerOutput = placeholderText.map(s => s.split(" "))
      }
      if (this.nerEnabled) {
        axios.get(
            `${this.api}/collection/${this.collection}/doc/${this.documentId}/ner`
        ).then(response => {
          this.nerOutput = response.data
          this.cachedNERDoc = response.data
        }).catch(err => {
          this.$emit("errorMsg", err)
          this.nerOutput = null
        }).then(() => {
          this.nerLoading = false
        })
      } else {
        axios.get(
            `${this.api}/collection/${this.collection}/doc/${this.documentId}?tokenize=1`
        ).then(response => {
          this.nerOutput = response.data.sentences
          this.cachedDoc = response.data.sentences
        }).catch(err => {
          this.$emit("errorMsg", err)
          this.nerOutput = null
        }).then(() => {
          this.nerLoading = false
        })
      }
    },
    onHoverToken(e) {
      const parts = e.target.id.split("-")
      const sentIdx = Number(parts[1])
      const tokenIdx = Number(parts[2])
      let token = this.nerOutput[sentIdx][tokenIdx]
      if (token.entity) {
        this.resolvedEntity = token.entity
      } else if (token.resolved_entity) {
        this.resolvedEntity = token.resolved_entity
      }
    },
    onLeaveToken() {
      this.resolvedEntity = null
    },
    unresolved(sentIdx, tokenIdx) {
      let token = this.nerOutput[sentIdx][tokenIdx]
      if (token.sent_idx !== undefined && !token.proper && (token.resolved_entity === null || !token.resolved_entity.proper)) {
        // entity, not a proper noun, not linked to a proper entity
        return true
      } else if (token.entity !== undefined && (token.entity === null || !token.entity.proper)) {
        return true
      }
      return false
    },
    onClickToken(e) {
      const parts = e.target.id.split("-")
      const sentIdx = Number(parts[1])
      const tokenIdx = Number(parts[2])
      this.$emit("selected", {sentIdx: sentIdx, tokenIdx: tokenIdx})
    },
  },
  mounted() {
    if (this.documentId) {
      this.loadNER()
    }
  }
}
</script>

<style scoped>
.el-popper {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.unresolved {
  text-decoration: underline dotted;
}

.highlighted {
  background-color: yellow;
}

.linker {
  position: -webkit-sticky; /* Safari & IE */
  width: 30%;
  height: inherit;
  overflow: scroll;
}

.token {
  padding-left: 2px;
  padding-right: 2px;
}

.sentence {
  display: flex;
  margin-bottom: 15px;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: flex-start;
  align-items: center;
}
</style>
