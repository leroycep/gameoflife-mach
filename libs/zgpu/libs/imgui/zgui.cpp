#include "./imgui/imgui.h"

#define ZGUI_API extern "C"

/*
#include <stdio.h>

ZGUI_API float zguiGetFloatMin(void) {
    printf("__FLT_MIN__ %.32e\n", __FLT_MIN__);
    return __FLT_MIN__;
}

ZGUI_API float zguiGetFloatMax(void) {
    printf("__FLT_MAX__ %.32e\n", __FLT_MAX__);
    return __FLT_MAX__;
}
*/

ZGUI_API void zguiSetNextWindowPos(float x, float y, ImGuiCond cond, float pivot_x, float pivot_y) {
    ImGui::SetNextWindowPos({ x, y }, cond, { pivot_x, pivot_y });
}

ZGUI_API void zguiSetNextWindowSize(float w, float h, ImGuiCond cond) {
    ImGui::SetNextWindowSize({ w, h }, cond);
}

ZGUI_API void zguiSetNextWindowCollapsed(bool collapsed, ImGuiCond cond) {
    ImGui::SetNextWindowCollapsed(collapsed, cond);
}

ZGUI_API void zguiSetNextWindowFocus(void) {
    ImGui::SetNextWindowFocus();
}

ZGUI_API void zguiSetNextWindowBgAlpha(float alpha) {
    ImGui::SetNextWindowBgAlpha(alpha);
}

ZGUI_API bool zguiBegin(const char* name, bool* p_open, ImGuiWindowFlags flags) {
    return ImGui::Begin(name, p_open, flags);
}

ZGUI_API void zguiEnd(void) {
    ImGui::End();
}

ZGUI_API bool zguiBeginChild(const char* str_id, float w, float h, bool border, ImGuiWindowFlags flags) {
    return ImGui::BeginChild(str_id, { w, h }, border, flags);
}

ZGUI_API bool zguiBeginChildId(ImGuiID id, float w, float h, bool border, ImGuiWindowFlags flags) {
    return ImGui::BeginChild(id, { w, h }, border, flags);
}

ZGUI_API void zguiEndChild(void) {
    ImGui::EndChild();
}

ZGUI_API float zguiGetScrollX(void) {
    return ImGui::GetScrollX();
}

ZGUI_API float zguiGetScrollY(void) {
    return ImGui::GetScrollY();
}

ZGUI_API void zguiSetScrollX(float scroll_x) {
    ImGui::SetScrollX(scroll_x);
}

ZGUI_API void zguiSetScrollY(float scroll_y) {
    ImGui::SetScrollY(scroll_y);
}

ZGUI_API float zguiGetScrollMaxX(void) {
    return ImGui::GetScrollMaxX();
}

ZGUI_API float zguiGetScrollMaxY(void) {
    return ImGui::GetScrollMaxY();
}

ZGUI_API void zguiSetScrollHereX(float center_x_ratio) {
    ImGui::SetScrollHereX(center_x_ratio);
}

ZGUI_API void zguiSetScrollHereY(float center_y_ratio) {
    ImGui::SetScrollHereY(center_y_ratio);
}

ZGUI_API void zguiSetScrollFromPosX(float local_x, float center_x_ratio) {
    ImGui::SetScrollFromPosX(local_x, center_x_ratio);
}

ZGUI_API void zguiSetScrollFromPosY(float local_y, float center_y_ratio) {
    ImGui::SetScrollFromPosY(local_y, center_y_ratio);
}

ZGUI_API bool zguiIsWindowAppearing(void) {
    return ImGui::IsWindowAppearing();
}

ZGUI_API bool zguiIsWindowCollapsed(void) {
    return ImGui::IsWindowCollapsed();
}

ZGUI_API bool zguiIsWindowFocused(ImGuiFocusedFlags flags) {
    return ImGui::IsWindowFocused(flags);
}

ZGUI_API bool zguiIsWindowHovered(ImGuiHoveredFlags flags) {
    return ImGui::IsWindowHovered(flags);
}

ZGUI_API void zguiGetWindowPos(float pos[2]) {
    const ImVec2 p = ImGui::GetWindowPos();
    pos[0] = p.x;
    pos[1] = p.y;
}

ZGUI_API void zguiGetWindowSize(float size[2]) {
    const ImVec2 s = ImGui::GetWindowSize();
    size[0] = s.x;
    size[1] = s.y;
}

ZGUI_API float zguiGetWindowWidth(void) {
    return ImGui::GetWindowWidth();
}

ZGUI_API float zguiGetWindowHeight(void) {
    return ImGui::GetWindowHeight();
}

ZGUI_API void zguiSpacing(void) {
    ImGui::Spacing();
}

ZGUI_API void zguiNewLine(void) {
    ImGui::NewLine();
}

ZGUI_API void zguiIndent(float indent_w) {
    ImGui::Indent(indent_w);
}

ZGUI_API void zguiUnindent(float indent_w) {
    ImGui::Unindent(indent_w);
}

ZGUI_API void zguiSeparator(void) {
    ImGui::Separator();
}

ZGUI_API void zguiSameLine(float offset_from_start_x, float spacing) {
    ImGui::SameLine(offset_from_start_x, spacing);
}

ZGUI_API void zguiDummy(float w, float h) {
    ImGui::Dummy({ w, h });
}

ZGUI_API void zguiBeginGroup(void) {
    ImGui::BeginGroup();
}

ZGUI_API void zguiEndGroup(void) {
    ImGui::EndGroup();
}

ZGUI_API void zguiGetCursorPos(float pos[2]) {
    const ImVec2 p = ImGui::GetCursorPos();
    pos[0] = p.x;
    pos[1] = p.y;
}

ZGUI_API float zguiGetCursorPosX() {
    return ImGui::GetCursorPosX();
}

ZGUI_API float zguiGetCursorPosY() {
    return ImGui::GetCursorPosY();
}

ZGUI_API void zguiSetCursorPos(float local_x, float local_y) {
    ImGui::SetCursorPos({ local_x, local_y });
}

ZGUI_API void zguiSetCursorPosX(float local_x) {
    ImGui::SetCursorPosX(local_x);
}

ZGUI_API void zguiSetCursorPosY(float local_y) {
    ImGui::SetCursorPosY(local_y);
}

ZGUI_API void zguiGetCursorStartPos(float pos[2]) {
    const ImVec2 p = ImGui::GetCursorStartPos();
    pos[0] = p.x;
    pos[1] = p.y;
}

ZGUI_API void zguiGetCursorScreenPos(float pos[2]) {
    const ImVec2 p = ImGui::GetCursorScreenPos();
    pos[0] = p.x;
    pos[1] = p.y;
}

ZGUI_API void zguiSetCursorScreenPos(float screen_x, float screen_y) {
    ImGui::SetCursorScreenPos({ screen_x, screen_y });
}

ZGUI_API void zguiAlignTextToFramePadding() {
    ImGui::AlignTextToFramePadding();
}

ZGUI_API float zguiGetTextLineHeight() {
    return ImGui::GetTextLineHeight();
}

ZGUI_API float zguiGetTextLineHeightWithSpacing() {
    return ImGui::GetTextLineHeightWithSpacing();
}

ZGUI_API float zguiGetFrameHeight() {
    return ImGui::GetFrameHeight();
}

ZGUI_API float zguiGetFrameHeightWithSpacing() {
    return ImGui::GetFrameHeightWithSpacing();
}

ZGUI_API bool zguiDragFloat(
    const char* label,
    float* v,
    float v_speed,
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragFloat(label, v, v_speed, v_min, v_max, format, flags);
}

ZGUI_API bool zguiDragFloat2(
    const char* label,
    float v[2],
    float v_speed,
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragFloat2(label, v, v_speed, v_min, v_max, format, flags);
}

ZGUI_API bool zguiDragFloat3(
    const char* label,
    float v[3],
    float v_speed,
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragFloat3(label, v, v_speed, v_min, v_max, format, flags);
}

ZGUI_API bool zguiDragFloat4(
    const char* label,
    float v[4],
    float v_speed,
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragFloat4(label, v, v_speed, v_min, v_max, format, flags);
}

ZGUI_API bool zguiDragFloatRange2(
    const char* label,
    float* v_current_min,
    float* v_current_max,
    float v_speed,
    float v_min,
    float v_max,
    const char* format,
    const char* format_max,
    ImGuiSliderFlags flags
) {
    return ImGui::DragFloatRange2(
        label,
        v_current_min,
        v_current_max,
        v_speed,
        v_min,
        v_max,
        format,
        format_max,
        flags
    );
}

ZGUI_API bool zguiDragInt(
    const char* label,
    int* v,
    float v_speed,
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragInt(label, v, v_speed, v_min, v_max, format, flags);
}

ZGUI_API bool zguiDragInt2(
    const char* label,
    int v[2],
    float v_speed,
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragInt2(label, v, v_speed, v_min, v_max, format, flags);
}

ZGUI_API bool zguiDragInt3(
    const char* label,
    int v[3],
    float v_speed,
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragInt3(label, v, v_speed, v_min, v_max, format, flags);
}

ZGUI_API bool zguiDragInt4(
    const char* label,
    int v[4],
    float v_speed,
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragInt4(label, v, v_speed, v_min, v_max, format, flags);
}

ZGUI_API bool zguiDragIntRange2(
    const char* label,
    int* v_current_min,
    int* v_current_max,
    float v_speed,
    int v_min,
    int v_max,
    const char* format,
    const char* format_max,
    ImGuiSliderFlags flags
) {
    return ImGui::DragIntRange2(
        label,
        v_current_min,
        v_current_max,
        v_speed,
        v_min,
        v_max,
        format,
        format_max,
        flags
    );
}

ZGUI_API bool zguiDragScalar(
    const char* label,
    ImGuiDataType data_type,
    void* p_data,
    float v_speed,
    const void* p_min,
    const void* p_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragScalar(label, data_type, p_data, v_speed, p_min, p_max, format, flags);
}

ZGUI_API bool zguiDragScalarN(
    const char* label,
    ImGuiDataType data_type,
    void* p_data,
    int components,
    float v_speed,
    const void* p_min,
    const void* p_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::DragScalarN(label, data_type, p_data, components, v_speed, p_min, p_max, format, flags);
}

ZGUI_API bool zguiCombo(
    const char* label,
    int* current_item,
    const char* items_separated_by_zeros,
    int popup_max_height_in_items
) {
    return ImGui::Combo(label, current_item, items_separated_by_zeros, popup_max_height_in_items);
}

ZGUI_API bool zguiBeginCombo(const char* label, const char* preview_value, ImGuiComboFlags flags) {
    return ImGui::BeginCombo(label, preview_value, flags);
}

ZGUI_API void zguiEndCombo(void) {
    ImGui::EndCombo();
}

ZGUI_API bool zguiBeginListBox(const char* label, float w, float h) {
    return ImGui::BeginListBox(label, { w, h });
}

ZGUI_API void zguiEndListBox(void) {
    ImGui::EndListBox();
}

ZGUI_API bool zguiSelectable(const char* label, bool selected, ImGuiSelectableFlags flags, float w, float h) {
    return ImGui::Selectable(label, selected, flags, { w, h });
}

ZGUI_API bool zguiSelectableStatePtr(
    const char* label,
    bool* p_selected,
    ImGuiSelectableFlags flags,
    float w,
    float h
) {
    return ImGui::Selectable(label, p_selected, flags, { w, h });
}

ZGUI_API bool zguiSliderFloat(
    const char* label,
    float* v,
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderFloat(label, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiSliderFloat2(
    const char* label,
    float v[2],
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderFloat2(label, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiSliderFloat3(
    const char* label,
    float v[3],
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderFloat3(label, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiSliderFloat4(
    const char* label,
    float v[4],
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderFloat4(label, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiSliderInt(
    const char* label,
    int* v,
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderInt(label, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiSliderInt2(
    const char* label,
    int v[2],
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderInt2(label, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiSliderInt3(
    const char* label,
    int v[3],
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderInt3(label, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiSliderInt4(
    const char* label,
    int v[4],
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderInt4(label, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiSliderScalar(
    const char* label,
    ImGuiDataType data_type,
    void* p_data,
    const void* p_min,
    const void* p_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderScalar(label, data_type, p_data, p_min, p_max, format, flags);
}

ZGUI_API bool zguiSliderScalarN(
    const char* label,
    ImGuiDataType data_type,
    void* p_data,
    int components,
    const void* p_min,
    const void* p_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderScalarN(label, data_type, p_data, components, p_min, p_max, format, flags);
}

ZGUI_API bool zguiVSliderFloat(
    const char* label,
    float w,
    float h,
    float* v,
    float v_min,
    float v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::VSliderFloat(label, { w, h }, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiVSliderInt(
    const char* label,
    float w,
    float h,
    int* v,
    int v_min,
    int v_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::VSliderInt(label, { w, h }, v, v_min, v_max, format, flags);
}

ZGUI_API bool zguiVSliderScalar(
    const char* label,
    float w,
    float h,
    ImGuiDataType data_type,
    void* p_data,
    const void* p_min,
    const void* p_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::VSliderScalar(label, { w, h }, data_type, p_data, p_min, p_max, format, flags);
}

ZGUI_API bool zguiSliderAngle(
    const char* label,
    float* v_rad,
    float v_degrees_min,
    float v_degrees_max,
    const char* format,
    ImGuiSliderFlags flags
) {
    return ImGui::SliderAngle(label, v_rad, v_degrees_min, v_degrees_max, format, flags);
}

ZGUI_API bool zguiInputFloat(
    const char* label,
    float* v,
    float step,
    float step_fast,
    const char* format,
    ImGuiInputTextFlags flags
) {
    return ImGui::InputFloat(label, v, step, step_fast, format, flags);
}

ZGUI_API bool zguiInputFloat2(
    const char* label,
    float v[2],
    const char* format,
    ImGuiInputTextFlags flags
) {
    return ImGui::InputFloat2(label, v, format, flags);
}

ZGUI_API bool zguiInputFloat3(
    const char* label,
    float v[3],
    const char* format,
    ImGuiInputTextFlags flags
) {
    return ImGui::InputFloat3(label, v, format, flags);
}

ZGUI_API bool zguiInputFloat4(
    const char* label,
    float v[4],
    const char* format,
    ImGuiInputTextFlags flags
) {
    return ImGui::InputFloat4(label, v, format, flags);
}

ZGUI_API bool zguiInputInt(
    const char* label,
    int* v,
    int step,
    int step_fast,
    ImGuiInputTextFlags flags
) {
    return ImGui::InputInt(label, v, step, step_fast, flags);
}

ZGUI_API bool zguiInputInt2(const char* label, int v[2], ImGuiInputTextFlags flags) {
    return ImGui::InputInt2(label, v, flags);
}

ZGUI_API bool zguiInputInt3(const char* label, int v[3], ImGuiInputTextFlags flags) {
    return ImGui::InputInt3(label, v, flags);
}

ZGUI_API bool zguiInputInt4(const char* label, int v[4], ImGuiInputTextFlags flags) {
    return ImGui::InputInt4(label, v, flags);
}

ZGUI_API bool zguiInputDouble(
    const char* label,
    double* v,
    double step,
    double step_fast,
    const char* format,
    ImGuiInputTextFlags flags
) {
    return ImGui::InputDouble(label, v, step, step_fast, format, flags);
}

ZGUI_API bool zguiInputScalar(
    const char* label,
    ImGuiDataType data_type,
    void* p_data,
    const void* p_step,
    const void* p_step_fast,
    const char* format,
    ImGuiInputTextFlags flags
) {
    return ImGui::InputScalar(label, data_type, p_data, p_step, p_step_fast, format, flags);
}

ZGUI_API bool zguiInputScalarN(
    const char* label,
    ImGuiDataType data_type,
    void* p_data,
    int components,
    const void* p_step,
    const void* p_step_fast,
    const char* format,
    ImGuiInputTextFlags flags
) {
    return ImGui::InputScalarN(label, data_type, p_data, components, p_step, p_step_fast, format, flags);
}

ZGUI_API bool zguiColorEdit3(const char* label, float col[3], ImGuiColorEditFlags flags) {
    return ImGui::ColorEdit3(label, col, flags);
}

ZGUI_API bool zguiColorEdit4(const char* label, float col[4], ImGuiColorEditFlags flags) {
    return ImGui::ColorEdit4(label, col, flags);
}

ZGUI_API bool zguiColorPicker3(const char* label, float col[3], ImGuiColorEditFlags flags) {
    return ImGui::ColorPicker3(label, col, flags);
}

ZGUI_API bool zguiColorPicker4(const char* label, float col[4], ImGuiColorEditFlags flags, const float* ref_col) {
    return ImGui::ColorPicker4(label, col, flags, ref_col);
}

ZGUI_API bool zguiColorButton(const char* desc_id, const float col[4], ImGuiColorEditFlags flags, float w, float h) {
    return ImGui::ColorButton(desc_id, { col[0], col[1], col[2], col[3] }, flags, { w, h });
}

ZGUI_API void zguiTextUnformatted(const char* text, const char* text_end) {
    ImGui::TextUnformatted(text, text_end);
}

ZGUI_API void zguiTextColored(const float col[4], const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::TextColoredV({ col[0], col[1], col[2], col[3] }, fmt, args);
    va_end(args);
}

ZGUI_API void zguiTextDisabled(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::TextDisabledV(fmt, args);
    va_end(args);
}

ZGUI_API void zguiTextWrapped(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::TextWrappedV(fmt, args);
    va_end(args);
}

ZGUI_API void zguiBulletText(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::BulletTextV(fmt, args);
    va_end(args);
}

ZGUI_API void zguiLabelText(const char* label, const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::LabelTextV(label, fmt, args);
    va_end(args);
}

ZGUI_API bool zguiButton(const char* label, float x, float y) {
    return ImGui::Button(label, { x, y });
}

ZGUI_API bool zguiSmallButton(const char* label) {
    return ImGui::SmallButton(label);
}

ZGUI_API bool zguiInvisibleButton(const char* str_id, float w, float h, ImGuiButtonFlags flags) {
    return ImGui::InvisibleButton(str_id, { w, h }, flags);
}

ZGUI_API bool zguiArrowButton(const char* str_id, ImGuiDir dir) {
    return ImGui::ArrowButton(str_id, dir);
}

ZGUI_API void zguiBullet(void) {
    ImGui::Bullet();
}

ZGUI_API bool zguiRadioButton(const char* label, bool active) {
    return ImGui::RadioButton(label, active);
}

ZGUI_API bool zguiRadioButtonStatePtr(const char* label, int* v, int v_button) {
    return ImGui::RadioButton(label, v, v_button);
}

ZGUI_API bool zguiCheckbox(const char* label, bool* v) {
    return ImGui::Checkbox(label, v);
}

ZGUI_API bool zguiCheckboxBits(const char* label, unsigned int* bits, unsigned int bits_value) {
    return ImGui::CheckboxFlags(label, bits, bits_value);
}

ZGUI_API void zguiProgressBar(float fraction, float w, float h, const char* overlay) {
    return ImGui::ProgressBar(fraction, { w, h }, overlay);
}

ZGUI_API ImGuiContext* zguiCreateContext(ImFontAtlas* shared_font_atlas) {
    return ImGui::CreateContext(shared_font_atlas);
}

ZGUI_API void zguiDestroyContext(ImGuiContext* ctx) {
    ImGui::DestroyContext(ctx);
}

ZGUI_API ImGuiContext* zguiGetCurrentContext(void) {
    return ImGui::GetCurrentContext();
}

ZGUI_API void zguiSetCurrentContext(ImGuiContext* ctx) {
    ImGui::SetCurrentContext(ctx);
}

ZGUI_API void zguiNewFrame(void) {
    ImGui::NewFrame();
}

ZGUI_API void zguiRender(void) {
    ImGui::Render();
}

ZGUI_API ImDrawData* zguiGetDrawData(void) {
    return ImGui::GetDrawData();
}

ZGUI_API void zguiShowDemoWindow(bool* p_open) {
    ImGui::ShowDemoWindow(p_open);
}

ZGUI_API void zguiBeginDisabled(bool disabled) {
    ImGui::BeginDisabled(disabled);
}

ZGUI_API void zguiEndDisabled(void) {
    ImGui::EndDisabled();
}

ZGUI_API void zguiPushStyleColor(ImGuiCol idx, const float col[4]) {
    ImGui::PushStyleColor(idx, { col[0], col[1], col[2], col[3] });
}

ZGUI_API void zguiPopStyleColor(int count) {
    ImGui::PopStyleColor(count);
}

ZGUI_API void zguiPushItemWidth(float item_width) {
    ImGui::PushItemWidth(item_width);
}

ZGUI_API void zguiPopItemWidth(void) {
    ImGui::PopItemWidth();
}

ZGUI_API void zguiSetNextItemWidth(float item_width) {
    ImGui::SetNextItemWidth(item_width);
}

ZGUI_API float zguiGetFontSize(void) {
    return ImGui::GetFontSize();
}

ZGUI_API bool zguiTreeNode(const char* label) {
    return ImGui::TreeNode(label);
}

ZGUI_API bool zguiTreeNodeStrId(const char* str_id, const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    const bool ret = ImGui::TreeNodeV(str_id, fmt, args);
    va_end(args);
    return ret;
}

ZGUI_API bool zguiTreeNodeStrIdFlags(const char* str_id, ImGuiTreeNodeFlags flags, const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    const bool ret = ImGui::TreeNodeExV(str_id, flags, fmt, args);
    va_end(args);
    return ret;
}

ZGUI_API bool zguiTreeNodePtrId(const void* ptr_id, const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    const bool ret = ImGui::TreeNodeV(ptr_id, fmt, args);
    va_end(args);
    return ret;
}

ZGUI_API bool zguiTreeNodePtrIdFlags(const void* ptr_id, ImGuiTreeNodeFlags flags, const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    const bool ret = ImGui::TreeNodeExV(ptr_id, flags, fmt, args);
    va_end(args);
    return ret;
}

ZGUI_API bool zguiCollapsingHeader(const char* label, ImGuiTreeNodeFlags flags) {
    return ImGui::CollapsingHeader(label, flags);
}

ZGUI_API bool zguiCollapsingHeaderStatePtr(const char* label, bool* p_visible, ImGuiTreeNodeFlags flags) {
    return ImGui::CollapsingHeader(label, p_visible, flags);
}

ZGUI_API void zguiSetNextItemOpen(bool is_open, ImGuiCond cond) {
    ImGui::SetNextItemOpen(is_open, cond);
}

ZGUI_API void zguiTreePushStrId(const char* str_id) {
    ImGui::TreePush(str_id);
}

ZGUI_API void zguiTreePushPtrId(const void* ptr_id) {
    ImGui::TreePush(ptr_id);
}

ZGUI_API void zguiTreePop(void) {
    ImGui::TreePop();
}

ZGUI_API void zguiPushStrId(const char* str_id_begin, const char* str_id_end) {
    ImGui::PushID(str_id_begin, str_id_end);
}

ZGUI_API void zguiPushStrIdZ(const char* str_id) {
    ImGui::PushID(str_id);
}

ZGUI_API void zguiPushPtrId(const void* ptr_id) {
    ImGui::PushID(ptr_id);
}

ZGUI_API void zguiPushIntId(int int_id) {
    ImGui::PushID(int_id);
}

ZGUI_API void zguiPopId(void) {
    ImGui::PopID();
}

ZGUI_API ImGuiID zguiGetStrId(const char* str_id_begin, const char* str_id_end) {
    return ImGui::GetID(str_id_begin, str_id_end);
}

ZGUI_API ImGuiID zguiGetStrIdZ(const char* str_id) {
    return ImGui::GetID(str_id);
}

ZGUI_API ImGuiID zguiGetPtrId(const void* ptr_id) {
    return ImGui::GetID(ptr_id);
}

ZGUI_API bool zguiIoGetWantCaptureMouse(void) {
    return ImGui::GetIO().WantCaptureMouse;
}

ZGUI_API bool zguiIoGetWantCaptureKeyboard(void) {
    return ImGui::GetIO().WantCaptureKeyboard;
}

ZGUI_API void zguiIoAddFontFromFile(const char* filename, float size_pixels) {
    ImGui::GetIO().Fonts->AddFontFromFileTTF(filename, size_pixels, nullptr, nullptr);
}

ZGUI_API void zguiIoSetIniFilename(const char* filename) {
    ImGui::GetIO().IniFilename = filename;
}

ZGUI_API void zguiIoSetDisplaySize(float width, float height) {
    ImGui::GetIO().DisplaySize = { width, height };
}

ZGUI_API void zguiIoSetDisplayFramebufferScale(float sx, float sy) {
    ImGui::GetIO().DisplayFramebufferScale = { sx, sy };
}

ZGUI_API bool zguiIsItemHovered(ImGuiHoveredFlags flags) {
    return ImGui::IsItemHovered(flags);
}

ZGUI_API bool zguiIsItemActive(void) {
    return ImGui::IsItemActive();
}

ZGUI_API bool zguiIsItemFocused(void) {
    return ImGui::IsItemFocused();
}

ZGUI_API bool zguiIsItemClicked(ImGuiMouseButton mouse_button) {
    return ImGui::IsItemClicked(mouse_button);
}

ZGUI_API bool zguiIsItemVisible(void) {
    return ImGui::IsItemVisible();
}

ZGUI_API bool zguiIsItemEdited(void) {
    return ImGui::IsItemEdited();
}

ZGUI_API bool zguiIsItemActivated(void) {
    return ImGui::IsItemActivated();
}

ZGUI_API bool zguiIsItemDeactivated(void) {
    return ImGui::IsItemDeactivated();
}

ZGUI_API bool zguiIsItemDeactivatedAfterEdit(void) {
    return ImGui::IsItemDeactivatedAfterEdit();
}

ZGUI_API bool zguiIsItemToggledOpen(void) {
    return ImGui::IsItemToggledOpen();
}

ZGUI_API bool zguiIsAnyItemHovered(void) {
    return ImGui::IsAnyItemHovered();
}

ZGUI_API bool zguiIsAnyItemActive(void) {
    return ImGui::IsAnyItemActive();
}

ZGUI_API bool zguiIsAnyItemFocused(void) {
    return ImGui::IsAnyItemFocused();
}
