//
//  WTSongListTableCellView.m
//  MacOSDemo
//
//  Created by 王腾 on 2022/9/27.
//

#import "WTSongListTableCellView.h"
#import <Masonry/Masonry.h>
@interface WTSongListTableCellView ()
@property (nonatomic, strong) NSTextField *nameLabel;
@property (nonatomic, strong) NSButton *button;
@end

@implementation WTSongListTableCellView

- (instancetype)initWithFrame:(NSRect)frameRect {
    
    if (self = [super initWithFrame:frameRect]) {
    
        [self bindView];
    }
    return self;
}
- (void)bindView {
    
    self.nameLabel = ({
       
        NSTextField *label = [[NSTextField alloc] init];
        label.editable = NO;
        label.font = [NSFont menuFontOfSize:12];
        label.backgroundColor = NSColor.redColor;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.leading.trailing.equalTo(self);
            make.centerY.equalTo(self);
        }];
        label;
        
    });
}
- (void)setName:(NSString *)name {
    _name = name;
    
    self.nameLabel.stringValue = _name;
}
@end
