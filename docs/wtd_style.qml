<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis simplifyMaxScale="1" symbologyReferenceScale="-1" version="3.24.0-Tisler" readOnly="0" simplifyLocal="1" labelsEnabled="0" simplifyDrawingTol="1" styleCategories="AllStyleCategories" hasScaleBasedVisibilityFlag="0" minScale="100000000" simplifyAlgorithm="0" simplifyDrawingHints="1" maxScale="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <temporal limitMode="0" durationUnit="min" mode="0" endField="" endExpression="" fixedDuration="0" durationField="OBJECTID" accumulate="0" startField="FDate" enabled="0" startExpression="">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <renderer-v2 referencescale="-1" symbollevels="0" enableorderby="0" type="RuleRenderer" forceraster="0">
    <rules key="{ea9873f8-4c5e-4975-9332-06c8996c298c}">
      <rule symbol="0" label="ephemeral" key="{2d8f69be-a875-4491-946d-b27502bc0929}" filter="&quot;perenniality&quot; = 'ephemeral'">
        <rule symbol="1" label="1" key="{4a1a45e3-6079-4dcd-b5c1-f35dadf1eb6b}" filter="StreamOrde = 1"/>
        <rule symbol="2" label="2" key="{9c48206a-b727-4922-93ec-484cfb4fb89e}" filter="StreamOrde = 2"/>
        <rule symbol="3" label="3" key="{32cfd7ac-6648-485d-a101-039bf0e010e2}" filter="StreamOrde = 3"/>
        <rule symbol="4" label="4" key="{51c79647-3f2f-4f69-80d0-48ef29fbff33}" filter="StreamOrde = 4"/>
        <rule symbol="5" label="5" key="{29048068-f4df-4de4-a347-03c8c54b4c5a}" filter="StreamOrde = 5"/>
        <rule symbol="6" label="6" key="{6ea0072e-7c6a-4707-890e-9a2cc796cdcf}" filter="StreamOrde = 6"/>
        <rule symbol="7" label="7" key="{fcbd8a76-d7fe-4612-81e9-d6036143e0d6}" filter="StreamOrde = 7"/>
        <rule symbol="8" label="8" key="{fcbd8a76-d7fe-4612-81e9-d6036143e0d6}" filter="StreamOrde = 8"/>
        <rule symbol="9" label="9+" key="{778ff45e-24b7-42a8-a6b0-2a873f4b4580}" filter="StreamOrde >=9"/>
      </rule>
      <rule symbol="10" label="intermittent" key="{f510d312-961e-4502-851b-a868dd7c2f13}" filter="&quot;perenniality&quot; = 'intermittent'">
        <rule symbol="11" label="1" key="{3cd1dd2e-9008-461c-93ae-df828ec80ef9}" filter="StreamOrde = 1"/>
        <rule symbol="12" label="2" key="{5f931d2c-a296-4df8-807c-c73838e42497}" filter="StreamOrde = 2"/>
        <rule symbol="13" label="3" key="{4a575191-b8e6-41a7-965e-66162594e06f}" filter="StreamOrde = 3"/>
        <rule symbol="14" label="4" key="{7755ca82-338a-417a-8996-2da597eb8fa8}" filter="StreamOrde = 4"/>
        <rule symbol="15" label="5" key="{a0d4fc42-526a-4120-b03f-0d43e1621ca8}" filter="StreamOrde = 5"/>
        <rule symbol="16" label="6" key="{ba464402-a51c-4908-8613-8c25581bf2ad}" filter="StreamOrde = 6"/>
        <rule symbol="17" label="7" key="{f076fede-a97e-42c1-92e9-851816b72884}" filter="StreamOrde = 7"/>
        <rule symbol="18" label="8" key="{f076fede-a97e-42c1-92e9-851816b72884}" filter="StreamOrde = 8"/>
        <rule symbol="19" label="9+" key="{a01bdca3-3b89-4ab1-b930-68715d950c51}" filter="StreamOrde >= 9"/>
      </rule>
      <rule symbol="20" label="perennial" key="{b017bd73-1c83-456f-8b2e-30f9064482af}" filter="&quot;perenniality&quot; = 'perennial'">
        <rule symbol="21" label="1" key="{668cc3d8-5ad3-474c-a726-29df2a58b5b9}" filter="StreamOrde = 1"/>
        <rule symbol="22" label="2" key="{f4a157ee-a7c6-49dd-859d-a60a5a9d6a0e}" filter="StreamOrde = 2"/>
        <rule symbol="23" label="3" key="{0beac4f8-dc47-4769-b225-988df429ab99}" filter="StreamOrde = 3"/>
        <rule symbol="24" label="4" key="{c1ba794e-ce67-45e4-ae15-a9490a40c68c}" filter="StreamOrde = 4"/>
        <rule symbol="25" label="5" key="{25c50d12-92ea-40b7-a239-50fade768985}" filter="StreamOrde = 5"/>
        <rule symbol="26" label="6" key="{440cad98-4c30-4468-afaf-ae13467ce130}" filter="StreamOrde = 6"/>
        <rule symbol="27" label="7" key="{c39783b8-b810-4eb9-b694-cb2018dd165b}" filter="StreamOrde = 7"/>
        <rule symbol="28" label="8" key="{c39783b8-b810-4eb9-b694-cb2018dd165b}" filter="StreamOrde = 8"/>
        <rule symbol="29" label="9+" key="{bccdd1a5-afb6-46a3-a7f0-6a53e445edec}" filter="StreamOrde >= 9"/>
      </rule>
      <rule symbol="30" checkstate="0" key="{0c3cb36d-e6a3-4d52-bb62-3ac7426cb727}" filter="ELSE"/>
    </rules>
    <symbols>
      <symbol alpha="1" clip_to_extent="1" name="0" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.26"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.26"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="1" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.1"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.1"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="10" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.26"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.26"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="11" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.1"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.1"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="12" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.37143"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.37143"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="13" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.64286"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.64286"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="14" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.91429"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.91429"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="15" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.18571"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.18571"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="16" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.45714"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.45714"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="17" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.72857"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="18" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.72857"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="19" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="232,113,141,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.72857"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="232,113,141,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="2" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.3375"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.3375"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="20" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.26"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.26"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="21" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.1"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.1"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="22" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.37143"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.37143"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="23" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.64286"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.64286"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="24" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.91429"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.91429"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="25" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.18571"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.18571"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="26" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.45714"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.45714"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="27" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.72857"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="28" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.72857"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="29" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="15,21,183,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.72857"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="15,21,183,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.72857"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="3" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.575"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.575"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="30" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="207,79,227,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.26"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="207,79,227,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.26"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="4" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="0.8125"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="0.8125"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="5" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.05"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.05"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="6" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.2875"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.2875"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="7" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.525"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.525"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="8" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.525"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.525"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
      <symbol alpha="1" clip_to_extent="1" name="9" force_rhr="0" type="line">
        <data_defined_properties>
          <Option type="Map">
            <Option name="name" type="QString" value=""/>
            <Option name="properties"/>
            <Option name="type" type="QString" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer locked="0" pass="0" class="SimpleLine" enabled="1">
          <Option type="Map">
            <Option name="align_dash_pattern" type="QString" value="0"/>
            <Option name="capstyle" type="QString" value="square"/>
            <Option name="customdash" type="QString" value="5;2"/>
            <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="customdash_unit" type="QString" value="MM"/>
            <Option name="dash_pattern_offset" type="QString" value="0"/>
            <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
            <Option name="draw_inside_polygon" type="QString" value="0"/>
            <Option name="joinstyle" type="QString" value="bevel"/>
            <Option name="line_color" type="QString" value="243,200,90,255"/>
            <Option name="line_style" type="QString" value="solid"/>
            <Option name="line_width" type="QString" value="1.525"/>
            <Option name="line_width_unit" type="QString" value="MM"/>
            <Option name="offset" type="QString" value="0"/>
            <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="offset_unit" type="QString" value="MM"/>
            <Option name="ring_filter" type="QString" value="0"/>
            <Option name="trim_distance_end" type="QString" value="0"/>
            <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_end_unit" type="QString" value="MM"/>
            <Option name="trim_distance_start" type="QString" value="0"/>
            <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            <Option name="trim_distance_start_unit" type="QString" value="MM"/>
            <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
            <Option name="use_custom_dash" type="QString" value="0"/>
            <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop k="align_dash_pattern" v="0"/>
          <prop k="capstyle" v="square"/>
          <prop k="customdash" v="5;2"/>
          <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="customdash_unit" v="MM"/>
          <prop k="dash_pattern_offset" v="0"/>
          <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="dash_pattern_offset_unit" v="MM"/>
          <prop k="draw_inside_polygon" v="0"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="line_color" v="243,200,90,255"/>
          <prop k="line_style" v="solid"/>
          <prop k="line_width" v="1.525"/>
          <prop k="line_width_unit" v="MM"/>
          <prop k="offset" v="0"/>
          <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="ring_filter" v="0"/>
          <prop k="trim_distance_end" v="0"/>
          <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_end_unit" v="MM"/>
          <prop k="trim_distance_start" v="0"/>
          <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <prop k="trim_distance_start_unit" v="MM"/>
          <prop k="tweak_dash_pattern_on_corners" v="0"/>
          <prop k="use_custom_dash" v="0"/>
          <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
  </renderer-v2>
  <customproperties>
    <Option type="Map">
      <Option name="dualview/previewExpressions" type="List">
        <Option type="QString" value="&quot;GNIS_Name&quot;"/>
      </Option>
      <Option name="embeddedWidgets/count" type="int" value="0"/>
      <Option name="variableNames"/>
      <Option name="variableValues"/>
    </Option>
  </customproperties>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
  <SingleCategoryDiagramRenderer attributeLegend="1" diagramType="Histogram">
    <DiagramCategory scaleBasedVisibility="0" lineSizeType="MM" backgroundColor="#ffffff" spacingUnitScale="3x:0,0,0,0,0,0" sizeScale="3x:0,0,0,0,0,0" backgroundAlpha="255" enabled="0" minScaleDenominator="0" penColor="#000000" minimumSize="0" direction="0" spacing="5" lineSizeScale="3x:0,0,0,0,0,0" showAxis="1" maxScaleDenominator="1e+08" height="15" spacingUnit="MM" width="15" penWidth="0" sizeType="MM" opacity="1" diagramOrientation="Up" penAlpha="255" rotationOffset="270" barWidth="5" labelPlacementMethod="XHeight" scaleDependency="Area">
      <fontProperties style="" description="MS Shell Dlg 2,9.5,-1,5,50,0,0,0,0,0"/>
      <attribute field="" label="" color="#000000"/>
      <axisSymbol>
        <symbol alpha="1" clip_to_extent="1" name="" force_rhr="0" type="line">
          <data_defined_properties>
            <Option type="Map">
              <Option name="name" type="QString" value=""/>
              <Option name="properties"/>
              <Option name="type" type="QString" value="collection"/>
            </Option>
          </data_defined_properties>
          <layer locked="0" pass="0" class="SimpleLine" enabled="1">
            <Option type="Map">
              <Option name="align_dash_pattern" type="QString" value="0"/>
              <Option name="capstyle" type="QString" value="square"/>
              <Option name="customdash" type="QString" value="5;2"/>
              <Option name="customdash_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
              <Option name="customdash_unit" type="QString" value="MM"/>
              <Option name="dash_pattern_offset" type="QString" value="0"/>
              <Option name="dash_pattern_offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
              <Option name="dash_pattern_offset_unit" type="QString" value="MM"/>
              <Option name="draw_inside_polygon" type="QString" value="0"/>
              <Option name="joinstyle" type="QString" value="bevel"/>
              <Option name="line_color" type="QString" value="35,35,35,255"/>
              <Option name="line_style" type="QString" value="solid"/>
              <Option name="line_width" type="QString" value="0.26"/>
              <Option name="line_width_unit" type="QString" value="MM"/>
              <Option name="offset" type="QString" value="0"/>
              <Option name="offset_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
              <Option name="offset_unit" type="QString" value="MM"/>
              <Option name="ring_filter" type="QString" value="0"/>
              <Option name="trim_distance_end" type="QString" value="0"/>
              <Option name="trim_distance_end_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
              <Option name="trim_distance_end_unit" type="QString" value="MM"/>
              <Option name="trim_distance_start" type="QString" value="0"/>
              <Option name="trim_distance_start_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
              <Option name="trim_distance_start_unit" type="QString" value="MM"/>
              <Option name="tweak_dash_pattern_on_corners" type="QString" value="0"/>
              <Option name="use_custom_dash" type="QString" value="0"/>
              <Option name="width_map_unit_scale" type="QString" value="3x:0,0,0,0,0,0"/>
            </Option>
            <prop k="align_dash_pattern" v="0"/>
            <prop k="capstyle" v="square"/>
            <prop k="customdash" v="5;2"/>
            <prop k="customdash_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="customdash_unit" v="MM"/>
            <prop k="dash_pattern_offset" v="0"/>
            <prop k="dash_pattern_offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="dash_pattern_offset_unit" v="MM"/>
            <prop k="draw_inside_polygon" v="0"/>
            <prop k="joinstyle" v="bevel"/>
            <prop k="line_color" v="35,35,35,255"/>
            <prop k="line_style" v="solid"/>
            <prop k="line_width" v="0.26"/>
            <prop k="line_width_unit" v="MM"/>
            <prop k="offset" v="0"/>
            <prop k="offset_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="offset_unit" v="MM"/>
            <prop k="ring_filter" v="0"/>
            <prop k="trim_distance_end" v="0"/>
            <prop k="trim_distance_end_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="trim_distance_end_unit" v="MM"/>
            <prop k="trim_distance_start" v="0"/>
            <prop k="trim_distance_start_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <prop k="trim_distance_start_unit" v="MM"/>
            <prop k="tweak_dash_pattern_on_corners" v="0"/>
            <prop k="use_custom_dash" v="0"/>
            <prop k="width_map_unit_scale" v="3x:0,0,0,0,0,0"/>
            <data_defined_properties>
              <Option type="Map">
                <Option name="name" type="QString" value=""/>
                <Option name="properties"/>
                <Option name="type" type="QString" value="collection"/>
              </Option>
            </data_defined_properties>
          </layer>
        </symbol>
      </axisSymbol>
    </DiagramCategory>
  </SingleCategoryDiagramRenderer>
  <DiagramLayerSettings dist="0" showAll="1" linePlacementFlags="18" zIndex="0" priority="0" obstacle="0" placement="2">
    <properties>
      <Option type="Map">
        <Option name="name" type="QString" value=""/>
        <Option name="properties"/>
        <Option name="type" type="QString" value="collection"/>
      </Option>
    </properties>
  </DiagramLayerSettings>
  <geometryOptions geometryPrecision="0" removeDuplicateNodes="0">
    <activeChecks/>
    <checkConfiguration/>
  </geometryOptions>
  <legend showLabelLegend="0" type="default-vector"/>
  <referencedLayers/>
  <fieldConfiguration>
    <field configurationFlags="None" name="OBJECTID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Permanent_Identifier">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FDate">
      <editWidget type="DateTime">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Resolution">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option name="map" type="List">
              <Option type="Map">
                <Option name="Local" type="QString" value="1"/>
              </Option>
              <Option type="Map">
                <Option name="High" type="QString" value="2"/>
              </Option>
              <Option type="Map">
                <Option name="Medium" type="QString" value="3"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="GNIS_ID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="GNIS_Name">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="LengthKM">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="ReachCode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FlowDir">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option name="map" type="List">
              <Option type="Map">
                <Option name="Uninitialized" type="QString" value="0"/>
              </Option>
              <Option type="Map">
                <Option name="WithDigitized" type="QString" value="1"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="WBArea_Permanent_Identifier">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FType">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FCode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="MainPath">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option name="map" type="List">
              <Option type="Map">
                <Option name="Unspecified" type="QString" value="0"/>
              </Option>
              <Option type="Map">
                <Option name="Confluence Main" type="QString" value="1"/>
              </Option>
              <Option type="Map">
                <Option name="Divergence Main" type="QString" value="2"/>
              </Option>
              <Option type="Map">
                <Option name="Both Confluence and Divergence Main" type="QString" value="3"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="InNetwork">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option name="map" type="List">
              <Option type="Map">
                <Option name="Yes" type="QString" value="1"/>
              </Option>
              <Option type="Map">
                <Option name="No" type="QString" value="0"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="VisibilityFilter">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option name="map" type="List">
              <Option type="Map">
                <Option name="Unspecified" type="QString" value="0"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:4,800 or Larger Scale" type="QString" value="4800"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:12,500 or Larger Scale" type="QString" value="12500"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:24,000 or Larger Scale" type="QString" value="24000"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:50,000 or Larger Scale" type="QString" value="50000"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:100,000 or Larger Scale" type="QString" value="100000"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:150,000 or Larger Scale" type="QString" value="150000"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:250,000 or Larger Scale" type="QString" value="250000"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:500,000 or Larger Scale" type="QString" value="500000"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:1,000,000 or Larger Scale" type="QString" value="1000000"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:2,000,000 or Larger Scale" type="QString" value="2000000"/>
              </Option>
              <Option type="Map">
                <Option name="Approximately 1:5,000,000 or Larger Scale" type="QString" value="5000000"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Shape_Length">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="NHDPlusID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="VPUID">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Enabled">
      <editWidget type="ValueMap">
        <config>
          <Option type="Map">
            <Option name="map" type="List">
              <Option type="Map">
                <Option name="False" type="QString" value="0"/>
              </Option>
              <Option type="Map">
                <Option name="True" type="QString" value="1"/>
              </Option>
            </Option>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="StreamOrde">
      <editWidget type="Range">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="HydroSeq">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="FromNode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="ToNode">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="Q_cms">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_01">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_02">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_03">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_04">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_05">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_06">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_07">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_08">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_09">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_10">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_11">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="wtd_m_12">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="width_m">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="perenniality">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" field="OBJECTID" name=""/>
    <alias index="1" field="Permanent_Identifier" name=""/>
    <alias index="2" field="FDate" name=""/>
    <alias index="3" field="Resolution" name=""/>
    <alias index="4" field="GNIS_ID" name=""/>
    <alias index="5" field="GNIS_Name" name=""/>
    <alias index="6" field="LengthKM" name=""/>
    <alias index="7" field="ReachCode" name=""/>
    <alias index="8" field="FlowDir" name=""/>
    <alias index="9" field="WBArea_Permanent_Identifier" name=""/>
    <alias index="10" field="FType" name=""/>
    <alias index="11" field="FCode" name=""/>
    <alias index="12" field="MainPath" name=""/>
    <alias index="13" field="InNetwork" name=""/>
    <alias index="14" field="VisibilityFilter" name=""/>
    <alias index="15" field="Shape_Length" name=""/>
    <alias index="16" field="NHDPlusID" name=""/>
    <alias index="17" field="VPUID" name=""/>
    <alias index="18" field="Enabled" name=""/>
    <alias index="19" field="StreamOrde" name=""/>
    <alias index="20" field="HydroSeq" name=""/>
    <alias index="21" field="FromNode" name=""/>
    <alias index="22" field="ToNode" name=""/>
    <alias index="23" field="Q_cms" name=""/>
    <alias index="24" field="wtd_m_01" name=""/>
    <alias index="25" field="wtd_m_02" name=""/>
    <alias index="26" field="wtd_m_03" name=""/>
    <alias index="27" field="wtd_m_04" name=""/>
    <alias index="28" field="wtd_m_05" name=""/>
    <alias index="29" field="wtd_m_06" name=""/>
    <alias index="30" field="wtd_m_07" name=""/>
    <alias index="31" field="wtd_m_08" name=""/>
    <alias index="32" field="wtd_m_09" name=""/>
    <alias index="33" field="wtd_m_10" name=""/>
    <alias index="34" field="wtd_m_11" name=""/>
    <alias index="35" field="wtd_m_12" name=""/>
    <alias index="36" field="width_m" name=""/>
    <alias index="37" field="perenniality" name=""/>
  </aliases>
  <defaults>
    <default applyOnUpdate="0" expression="" field="OBJECTID"/>
    <default applyOnUpdate="0" expression="" field="Permanent_Identifier"/>
    <default applyOnUpdate="0" expression="" field="FDate"/>
    <default applyOnUpdate="0" expression="" field="Resolution"/>
    <default applyOnUpdate="0" expression="" field="GNIS_ID"/>
    <default applyOnUpdate="0" expression="" field="GNIS_Name"/>
    <default applyOnUpdate="0" expression="" field="LengthKM"/>
    <default applyOnUpdate="0" expression="" field="ReachCode"/>
    <default applyOnUpdate="0" expression="" field="FlowDir"/>
    <default applyOnUpdate="0" expression="" field="WBArea_Permanent_Identifier"/>
    <default applyOnUpdate="0" expression="" field="FType"/>
    <default applyOnUpdate="0" expression="" field="FCode"/>
    <default applyOnUpdate="0" expression="" field="MainPath"/>
    <default applyOnUpdate="0" expression="" field="InNetwork"/>
    <default applyOnUpdate="0" expression="" field="VisibilityFilter"/>
    <default applyOnUpdate="0" expression="" field="Shape_Length"/>
    <default applyOnUpdate="0" expression="" field="NHDPlusID"/>
    <default applyOnUpdate="0" expression="" field="VPUID"/>
    <default applyOnUpdate="0" expression="" field="Enabled"/>
    <default applyOnUpdate="0" expression="" field="StreamOrde"/>
    <default applyOnUpdate="0" expression="" field="HydroSeq"/>
    <default applyOnUpdate="0" expression="" field="FromNode"/>
    <default applyOnUpdate="0" expression="" field="ToNode"/>
    <default applyOnUpdate="0" expression="" field="Q_cms"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_01"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_02"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_03"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_04"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_05"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_06"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_07"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_08"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_09"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_10"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_11"/>
    <default applyOnUpdate="0" expression="" field="wtd_m_12"/>
    <default applyOnUpdate="0" expression="" field="width_m"/>
    <default applyOnUpdate="0" expression="" field="perenniality"/>
  </defaults>
  <constraints>
    <constraint exp_strength="0" field="OBJECTID" constraints="3" notnull_strength="1" unique_strength="1"/>
    <constraint exp_strength="0" field="Permanent_Identifier" constraints="1" notnull_strength="1" unique_strength="0"/>
    <constraint exp_strength="0" field="FDate" constraints="1" notnull_strength="1" unique_strength="0"/>
    <constraint exp_strength="0" field="Resolution" constraints="1" notnull_strength="1" unique_strength="0"/>
    <constraint exp_strength="0" field="GNIS_ID" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="GNIS_Name" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="LengthKM" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ReachCode" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="FlowDir" constraints="1" notnull_strength="1" unique_strength="0"/>
    <constraint exp_strength="0" field="WBArea_Permanent_Identifier" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="FType" constraints="1" notnull_strength="1" unique_strength="0"/>
    <constraint exp_strength="0" field="FCode" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="MainPath" constraints="1" notnull_strength="1" unique_strength="0"/>
    <constraint exp_strength="0" field="InNetwork" constraints="1" notnull_strength="1" unique_strength="0"/>
    <constraint exp_strength="0" field="VisibilityFilter" constraints="1" notnull_strength="1" unique_strength="0"/>
    <constraint exp_strength="0" field="Shape_Length" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="NHDPlusID" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="VPUID" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Enabled" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="StreamOrde" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="HydroSeq" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="FromNode" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="ToNode" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="Q_cms" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_01" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_02" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_03" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_04" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_05" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_06" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_07" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_08" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_09" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_10" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_11" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="wtd_m_12" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="width_m" constraints="0" notnull_strength="0" unique_strength="0"/>
    <constraint exp_strength="0" field="perenniality" constraints="0" notnull_strength="0" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="OBJECTID" exp="" desc=""/>
    <constraint field="Permanent_Identifier" exp="" desc=""/>
    <constraint field="FDate" exp="" desc=""/>
    <constraint field="Resolution" exp="" desc=""/>
    <constraint field="GNIS_ID" exp="" desc=""/>
    <constraint field="GNIS_Name" exp="" desc=""/>
    <constraint field="LengthKM" exp="" desc=""/>
    <constraint field="ReachCode" exp="" desc=""/>
    <constraint field="FlowDir" exp="" desc=""/>
    <constraint field="WBArea_Permanent_Identifier" exp="" desc=""/>
    <constraint field="FType" exp="" desc=""/>
    <constraint field="FCode" exp="" desc=""/>
    <constraint field="MainPath" exp="" desc=""/>
    <constraint field="InNetwork" exp="" desc=""/>
    <constraint field="VisibilityFilter" exp="" desc=""/>
    <constraint field="Shape_Length" exp="" desc=""/>
    <constraint field="NHDPlusID" exp="" desc=""/>
    <constraint field="VPUID" exp="" desc=""/>
    <constraint field="Enabled" exp="" desc=""/>
    <constraint field="StreamOrde" exp="" desc=""/>
    <constraint field="HydroSeq" exp="" desc=""/>
    <constraint field="FromNode" exp="" desc=""/>
    <constraint field="ToNode" exp="" desc=""/>
    <constraint field="Q_cms" exp="" desc=""/>
    <constraint field="wtd_m_01" exp="" desc=""/>
    <constraint field="wtd_m_02" exp="" desc=""/>
    <constraint field="wtd_m_03" exp="" desc=""/>
    <constraint field="wtd_m_04" exp="" desc=""/>
    <constraint field="wtd_m_05" exp="" desc=""/>
    <constraint field="wtd_m_06" exp="" desc=""/>
    <constraint field="wtd_m_07" exp="" desc=""/>
    <constraint field="wtd_m_08" exp="" desc=""/>
    <constraint field="wtd_m_09" exp="" desc=""/>
    <constraint field="wtd_m_10" exp="" desc=""/>
    <constraint field="wtd_m_11" exp="" desc=""/>
    <constraint field="wtd_m_12" exp="" desc=""/>
    <constraint field="width_m" exp="" desc=""/>
    <constraint field="perenniality" exp="" desc=""/>
  </constraintExpressions>
  <expressionfields/>
  <attributeactions>
    <defaultAction key="Canvas" value="{00000000-0000-0000-0000-000000000000}"/>
  </attributeactions>
  <attributetableconfig actionWidgetStyle="dropDown" sortExpression="" sortOrder="0">
    <columns>
      <column hidden="0" width="-1" name="OBJECTID" type="field"/>
      <column hidden="0" width="-1" name="Permanent_Identifier" type="field"/>
      <column hidden="0" width="-1" name="FDate" type="field"/>
      <column hidden="0" width="-1" name="Resolution" type="field"/>
      <column hidden="0" width="-1" name="GNIS_ID" type="field"/>
      <column hidden="0" width="-1" name="GNIS_Name" type="field"/>
      <column hidden="0" width="-1" name="LengthKM" type="field"/>
      <column hidden="0" width="-1" name="ReachCode" type="field"/>
      <column hidden="0" width="-1" name="FlowDir" type="field"/>
      <column hidden="0" width="-1" name="WBArea_Permanent_Identifier" type="field"/>
      <column hidden="0" width="-1" name="FType" type="field"/>
      <column hidden="0" width="-1" name="FCode" type="field"/>
      <column hidden="0" width="-1" name="MainPath" type="field"/>
      <column hidden="0" width="-1" name="InNetwork" type="field"/>
      <column hidden="0" width="-1" name="VisibilityFilter" type="field"/>
      <column hidden="0" width="-1" name="Shape_Length" type="field"/>
      <column hidden="0" width="-1" name="NHDPlusID" type="field"/>
      <column hidden="0" width="-1" name="VPUID" type="field"/>
      <column hidden="0" width="-1" name="Enabled" type="field"/>
      <column hidden="0" width="-1" name="StreamOrde" type="field"/>
      <column hidden="0" width="-1" name="HydroSeq" type="field"/>
      <column hidden="0" width="-1" name="FromNode" type="field"/>
      <column hidden="0" width="-1" name="ToNode" type="field"/>
      <column hidden="0" width="-1" name="Q_cms" type="field"/>
      <column hidden="0" width="-1" name="width_m" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_01" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_02" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_03" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_04" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_05" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_06" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_07" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_08" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_09" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_10" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_11" type="field"/>
      <column hidden="0" width="-1" name="wtd_m_12" type="field"/>
      <column hidden="0" width="-1" name="perenniality" type="field"/>
      <column hidden="1" width="-1" type="actions"/>
    </columns>
  </attributetableconfig>
  <conditionalstyles>
    <rowstyles/>
    <fieldstyles/>
  </conditionalstyles>
  <storedexpressions/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
    geom = feature.geometry()
    control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>generatedlayout</editorlayout>
  <editable>
    <field editable="0" name="1104_FromNode"/>
    <field editable="0" name="1104_HydroSeq"/>
    <field editable="0" name="1104_LengthKM"/>
    <field editable="0" name="1104_Q_cms"/>
    <field editable="0" name="1104_StreamOrde"/>
    <field editable="0" name="1104_ToNode"/>
    <field editable="0" name="1104_field_1"/>
    <field editable="0" name="1104_perenniality"/>
    <field editable="0" name="1104_width_m"/>
    <field editable="0" name="1104_wtd_m_01"/>
    <field editable="0" name="1104_wtd_m_02"/>
    <field editable="0" name="1104_wtd_m_03"/>
    <field editable="0" name="1104_wtd_m_04"/>
    <field editable="0" name="1104_wtd_m_05"/>
    <field editable="0" name="1104_wtd_m_06"/>
    <field editable="0" name="1104_wtd_m_07"/>
    <field editable="0" name="1104_wtd_m_08"/>
    <field editable="0" name="1104_wtd_m_09"/>
    <field editable="0" name="1104_wtd_m_10"/>
    <field editable="0" name="1104_wtd_m_11"/>
    <field editable="0" name="1104_wtd_m_12"/>
    <field editable="0" name="1104_wtd_sum"/>
    <field editable="0" name="1114_FromNode"/>
    <field editable="0" name="1114_HydroSeq"/>
    <field editable="0" name="1114_LengthKM"/>
    <field editable="0" name="1114_Q_cms"/>
    <field editable="0" name="1114_StreamOrde"/>
    <field editable="0" name="1114_ToNode"/>
    <field editable="0" name="1114_field_1"/>
    <field editable="0" name="1114_perenniality"/>
    <field editable="0" name="1114_width_m"/>
    <field editable="0" name="1114_wtd_m_01"/>
    <field editable="0" name="1114_wtd_m_02"/>
    <field editable="0" name="1114_wtd_m_03"/>
    <field editable="0" name="1114_wtd_m_04"/>
    <field editable="0" name="1114_wtd_m_05"/>
    <field editable="0" name="1114_wtd_m_06"/>
    <field editable="0" name="1114_wtd_m_07"/>
    <field editable="0" name="1114_wtd_m_08"/>
    <field editable="0" name="1114_wtd_m_09"/>
    <field editable="0" name="1114_wtd_m_10"/>
    <field editable="0" name="1114_wtd_m_11"/>
    <field editable="0" name="1114_wtd_m_12"/>
    <field editable="0" name="1114_wtd_sum"/>
    <field editable="1" name="Enabled"/>
    <field editable="1" name="FCode"/>
    <field editable="1" name="FDate"/>
    <field editable="1" name="FType"/>
    <field editable="1" name="FlowDir"/>
    <field editable="0" name="FromNode"/>
    <field editable="1" name="GNIS_ID"/>
    <field editable="1" name="GNIS_Name"/>
    <field editable="0" name="HydroSeq"/>
    <field editable="1" name="InNetwork"/>
    <field editable="1" name="LengthKM"/>
    <field editable="1" name="MainPath"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ArbolateSu"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_AreaSqKm"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DivDASqKm"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Divergence"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnDrainCou"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnHydroSeq"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevel"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevelPat"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnMinorHyd"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ElevFixed"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromMeas"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromNode"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWNodeSqKm"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWType"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HydroSeq"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_LevelPathI"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevRaw"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevSmo"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevRaw"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevSmo"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_OBJECTID"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_PathLength"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ReachCode"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_RtnDiv"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Slope"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_SlopeLenKm"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StartFlag"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StatusFlag"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamCalc"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamLeve"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamOrde"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalFl"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalPa"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Thinner"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToMeas"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToNode"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TotDASqKm"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpHydroSeq"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpLevelPat"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUID"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUIn"/>
    <field editable="0" name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUOut"/>
    <field editable="1" name="NHDPlusID"/>
    <field editable="1" name="OBJECTID"/>
    <field editable="1" name="Permanent_Identifier"/>
    <field editable="0" name="Q_cms"/>
    <field editable="1" name="ReachCode"/>
    <field editable="1" name="Resolution"/>
    <field editable="1" name="Shape_Length"/>
    <field editable="0" name="StreamOrde"/>
    <field editable="0" name="ToNode"/>
    <field editable="1" name="VPUID"/>
    <field editable="1" name="VisibilityFilter"/>
    <field editable="1" name="WBArea_Permanent_Identifier"/>
    <field editable="0" name="field_1"/>
    <field editable="0" name="perenniality"/>
    <field editable="0" name="width_m"/>
    <field editable="0" name="wtd_m_01"/>
    <field editable="0" name="wtd_m_02"/>
    <field editable="0" name="wtd_m_03"/>
    <field editable="0" name="wtd_m_04"/>
    <field editable="0" name="wtd_m_05"/>
    <field editable="0" name="wtd_m_06"/>
    <field editable="0" name="wtd_m_07"/>
    <field editable="0" name="wtd_m_08"/>
    <field editable="0" name="wtd_m_09"/>
    <field editable="0" name="wtd_m_10"/>
    <field editable="0" name="wtd_m_11"/>
    <field editable="0" name="wtd_m_12"/>
    <field editable="0" name="wtd_sum"/>
  </editable>
  <labelOnTop>
    <field name="1104_FromNode" labelOnTop="0"/>
    <field name="1104_HydroSeq" labelOnTop="0"/>
    <field name="1104_LengthKM" labelOnTop="0"/>
    <field name="1104_Q_cms" labelOnTop="0"/>
    <field name="1104_StreamOrde" labelOnTop="0"/>
    <field name="1104_ToNode" labelOnTop="0"/>
    <field name="1104_field_1" labelOnTop="0"/>
    <field name="1104_perenniality" labelOnTop="0"/>
    <field name="1104_width_m" labelOnTop="0"/>
    <field name="1104_wtd_m_01" labelOnTop="0"/>
    <field name="1104_wtd_m_02" labelOnTop="0"/>
    <field name="1104_wtd_m_03" labelOnTop="0"/>
    <field name="1104_wtd_m_04" labelOnTop="0"/>
    <field name="1104_wtd_m_05" labelOnTop="0"/>
    <field name="1104_wtd_m_06" labelOnTop="0"/>
    <field name="1104_wtd_m_07" labelOnTop="0"/>
    <field name="1104_wtd_m_08" labelOnTop="0"/>
    <field name="1104_wtd_m_09" labelOnTop="0"/>
    <field name="1104_wtd_m_10" labelOnTop="0"/>
    <field name="1104_wtd_m_11" labelOnTop="0"/>
    <field name="1104_wtd_m_12" labelOnTop="0"/>
    <field name="1104_wtd_sum" labelOnTop="0"/>
    <field name="1114_FromNode" labelOnTop="0"/>
    <field name="1114_HydroSeq" labelOnTop="0"/>
    <field name="1114_LengthKM" labelOnTop="0"/>
    <field name="1114_Q_cms" labelOnTop="0"/>
    <field name="1114_StreamOrde" labelOnTop="0"/>
    <field name="1114_ToNode" labelOnTop="0"/>
    <field name="1114_field_1" labelOnTop="0"/>
    <field name="1114_perenniality" labelOnTop="0"/>
    <field name="1114_width_m" labelOnTop="0"/>
    <field name="1114_wtd_m_01" labelOnTop="0"/>
    <field name="1114_wtd_m_02" labelOnTop="0"/>
    <field name="1114_wtd_m_03" labelOnTop="0"/>
    <field name="1114_wtd_m_04" labelOnTop="0"/>
    <field name="1114_wtd_m_05" labelOnTop="0"/>
    <field name="1114_wtd_m_06" labelOnTop="0"/>
    <field name="1114_wtd_m_07" labelOnTop="0"/>
    <field name="1114_wtd_m_08" labelOnTop="0"/>
    <field name="1114_wtd_m_09" labelOnTop="0"/>
    <field name="1114_wtd_m_10" labelOnTop="0"/>
    <field name="1114_wtd_m_11" labelOnTop="0"/>
    <field name="1114_wtd_m_12" labelOnTop="0"/>
    <field name="1114_wtd_sum" labelOnTop="0"/>
    <field name="Enabled" labelOnTop="0"/>
    <field name="FCode" labelOnTop="0"/>
    <field name="FDate" labelOnTop="0"/>
    <field name="FType" labelOnTop="0"/>
    <field name="FlowDir" labelOnTop="0"/>
    <field name="FromNode" labelOnTop="0"/>
    <field name="GNIS_ID" labelOnTop="0"/>
    <field name="GNIS_Name" labelOnTop="0"/>
    <field name="HydroSeq" labelOnTop="0"/>
    <field name="InNetwork" labelOnTop="0"/>
    <field name="LengthKM" labelOnTop="0"/>
    <field name="MainPath" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ArbolateSu" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_AreaSqKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DivDASqKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Divergence" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnDrainCou" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnHydroSeq" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevel" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevelPat" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnMinorHyd" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ElevFixed" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromMeas" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromNode" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWNodeSqKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWType" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HydroSeq" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_LevelPathI" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevRaw" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevSmo" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevRaw" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevSmo" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_OBJECTID" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_PathLength" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ReachCode" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_RtnDiv" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Slope" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_SlopeLenKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StartFlag" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StatusFlag" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamCalc" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamLeve" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamOrde" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalFl" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalPa" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Thinner" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToMeas" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToNode" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TotDASqKm" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpHydroSeq" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpLevelPat" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUID" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUIn" labelOnTop="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUOut" labelOnTop="0"/>
    <field name="NHDPlusID" labelOnTop="0"/>
    <field name="OBJECTID" labelOnTop="0"/>
    <field name="Permanent_Identifier" labelOnTop="0"/>
    <field name="Q_cms" labelOnTop="0"/>
    <field name="ReachCode" labelOnTop="0"/>
    <field name="Resolution" labelOnTop="0"/>
    <field name="Shape_Length" labelOnTop="0"/>
    <field name="StreamOrde" labelOnTop="0"/>
    <field name="ToNode" labelOnTop="0"/>
    <field name="VPUID" labelOnTop="0"/>
    <field name="VisibilityFilter" labelOnTop="0"/>
    <field name="WBArea_Permanent_Identifier" labelOnTop="0"/>
    <field name="field_1" labelOnTop="0"/>
    <field name="perenniality" labelOnTop="0"/>
    <field name="width_m" labelOnTop="0"/>
    <field name="wtd_m_01" labelOnTop="0"/>
    <field name="wtd_m_02" labelOnTop="0"/>
    <field name="wtd_m_03" labelOnTop="0"/>
    <field name="wtd_m_04" labelOnTop="0"/>
    <field name="wtd_m_05" labelOnTop="0"/>
    <field name="wtd_m_06" labelOnTop="0"/>
    <field name="wtd_m_07" labelOnTop="0"/>
    <field name="wtd_m_08" labelOnTop="0"/>
    <field name="wtd_m_09" labelOnTop="0"/>
    <field name="wtd_m_10" labelOnTop="0"/>
    <field name="wtd_m_11" labelOnTop="0"/>
    <field name="wtd_m_12" labelOnTop="0"/>
    <field name="wtd_sum" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="1104_FromNode" reuseLastValue="0"/>
    <field name="1104_HydroSeq" reuseLastValue="0"/>
    <field name="1104_LengthKM" reuseLastValue="0"/>
    <field name="1104_Q_cms" reuseLastValue="0"/>
    <field name="1104_StreamOrde" reuseLastValue="0"/>
    <field name="1104_ToNode" reuseLastValue="0"/>
    <field name="1104_field_1" reuseLastValue="0"/>
    <field name="1104_perenniality" reuseLastValue="0"/>
    <field name="1104_width_m" reuseLastValue="0"/>
    <field name="1104_wtd_m_01" reuseLastValue="0"/>
    <field name="1104_wtd_m_02" reuseLastValue="0"/>
    <field name="1104_wtd_m_03" reuseLastValue="0"/>
    <field name="1104_wtd_m_04" reuseLastValue="0"/>
    <field name="1104_wtd_m_05" reuseLastValue="0"/>
    <field name="1104_wtd_m_06" reuseLastValue="0"/>
    <field name="1104_wtd_m_07" reuseLastValue="0"/>
    <field name="1104_wtd_m_08" reuseLastValue="0"/>
    <field name="1104_wtd_m_09" reuseLastValue="0"/>
    <field name="1104_wtd_m_10" reuseLastValue="0"/>
    <field name="1104_wtd_m_11" reuseLastValue="0"/>
    <field name="1104_wtd_m_12" reuseLastValue="0"/>
    <field name="1104_wtd_sum" reuseLastValue="0"/>
    <field name="1114_FromNode" reuseLastValue="0"/>
    <field name="1114_HydroSeq" reuseLastValue="0"/>
    <field name="1114_LengthKM" reuseLastValue="0"/>
    <field name="1114_Q_cms" reuseLastValue="0"/>
    <field name="1114_StreamOrde" reuseLastValue="0"/>
    <field name="1114_ToNode" reuseLastValue="0"/>
    <field name="1114_field_1" reuseLastValue="0"/>
    <field name="1114_perenniality" reuseLastValue="0"/>
    <field name="1114_width_m" reuseLastValue="0"/>
    <field name="1114_wtd_m_01" reuseLastValue="0"/>
    <field name="1114_wtd_m_02" reuseLastValue="0"/>
    <field name="1114_wtd_m_03" reuseLastValue="0"/>
    <field name="1114_wtd_m_04" reuseLastValue="0"/>
    <field name="1114_wtd_m_05" reuseLastValue="0"/>
    <field name="1114_wtd_m_06" reuseLastValue="0"/>
    <field name="1114_wtd_m_07" reuseLastValue="0"/>
    <field name="1114_wtd_m_08" reuseLastValue="0"/>
    <field name="1114_wtd_m_09" reuseLastValue="0"/>
    <field name="1114_wtd_m_10" reuseLastValue="0"/>
    <field name="1114_wtd_m_11" reuseLastValue="0"/>
    <field name="1114_wtd_m_12" reuseLastValue="0"/>
    <field name="1114_wtd_sum" reuseLastValue="0"/>
    <field name="Enabled" reuseLastValue="0"/>
    <field name="FCode" reuseLastValue="0"/>
    <field name="FDate" reuseLastValue="0"/>
    <field name="FType" reuseLastValue="0"/>
    <field name="FlowDir" reuseLastValue="0"/>
    <field name="FromNode" reuseLastValue="0"/>
    <field name="GNIS_ID" reuseLastValue="0"/>
    <field name="GNIS_Name" reuseLastValue="0"/>
    <field name="HydroSeq" reuseLastValue="0"/>
    <field name="InNetwork" reuseLastValue="0"/>
    <field name="LengthKM" reuseLastValue="0"/>
    <field name="MainPath" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ArbolateSu" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_AreaSqKm" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DivDASqKm" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Divergence" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnDrainCou" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnHydroSeq" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevel" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnLevelPat" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_DnMinorHyd" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ElevFixed" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromMeas" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_FromNode" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWNodeSqKm" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HWType" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_HydroSeq" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_LevelPathI" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevRaw" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MaxElevSmo" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevRaw" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_MinElevSmo" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_OBJECTID" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_PathLength" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ReachCode" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_RtnDiv" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Slope" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_SlopeLenKm" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StartFlag" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StatusFlag" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamCalc" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamLeve" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_StreamOrde" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalFl" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TerminalPa" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_Thinner" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToMeas" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_ToNode" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_TotDASqKm" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpHydroSeq" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_UpLevelPat" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUID" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUIn" reuseLastValue="0"/>
    <field name="NHDPLUS_H_1114_HU4_GDB — NHDPlusFlowlineVAA_VPUOut" reuseLastValue="0"/>
    <field name="NHDPlusID" reuseLastValue="0"/>
    <field name="OBJECTID" reuseLastValue="0"/>
    <field name="Permanent_Identifier" reuseLastValue="0"/>
    <field name="Q_cms" reuseLastValue="0"/>
    <field name="ReachCode" reuseLastValue="0"/>
    <field name="Resolution" reuseLastValue="0"/>
    <field name="Shape_Length" reuseLastValue="0"/>
    <field name="StreamOrde" reuseLastValue="0"/>
    <field name="ToNode" reuseLastValue="0"/>
    <field name="VPUID" reuseLastValue="0"/>
    <field name="VisibilityFilter" reuseLastValue="0"/>
    <field name="WBArea_Permanent_Identifier" reuseLastValue="0"/>
    <field name="field_1" reuseLastValue="0"/>
    <field name="perenniality" reuseLastValue="0"/>
    <field name="width_m" reuseLastValue="0"/>
    <field name="wtd_m_01" reuseLastValue="0"/>
    <field name="wtd_m_02" reuseLastValue="0"/>
    <field name="wtd_m_03" reuseLastValue="0"/>
    <field name="wtd_m_04" reuseLastValue="0"/>
    <field name="wtd_m_05" reuseLastValue="0"/>
    <field name="wtd_m_06" reuseLastValue="0"/>
    <field name="wtd_m_07" reuseLastValue="0"/>
    <field name="wtd_m_08" reuseLastValue="0"/>
    <field name="wtd_m_09" reuseLastValue="0"/>
    <field name="wtd_m_10" reuseLastValue="0"/>
    <field name="wtd_m_11" reuseLastValue="0"/>
    <field name="wtd_m_12" reuseLastValue="0"/>
    <field name="wtd_sum" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <previewExpression>"GNIS_Name"</previewExpression>
  <mapTip></mapTip>
  <layerGeometryType>1</layerGeometryType>
</qgis>
